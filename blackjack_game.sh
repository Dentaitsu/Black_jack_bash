#!/bin/bash

cards=("2♠" "3♠" "4♠" "5♠" "6♠" "7♠" "8♠" "9♠" "10♠" "J♠" "Q♠" "K♠" "A♠"
       "2♥" "3♥" "4♥" "5♥" "6♥" "7♥" "8♥" "9♥" "10♥" "J♥" "Q♥" "K♥" "A♥"
       "2♦" "3♦" "4♦" "5♦" "6♦" "7♦" "8♦" "9♦" "10♦" "J♦" "Q♦" "K♦" "A♦"
       "2♣" "3♣" "4♣" "5♣" "6♣" "7♣" "8♣" "9♣" "10♣" "J♣" "Q♣" "K♣" "A♣")

declare -A card_values=( ["2"]=2 ["3"]=3 ["4"]=4 ["5"]=5 ["6"]=6 ["7"]=7 ["8"]=8 ["9"]=9 ["10"]=10 
                         ["J"]=10 ["Q"]=10 ["K"]=10 ["A"]=11 )

currency=100

function slow_text {
    local text="$1"
    local delay="${2:-0.05}"
    for ((i=0; i<${#text}; i++)); do
        echo -n "${text:i:1}"
        sleep "$delay"
    done
    echo
}

function draw_card {
    echo "${cards[$RANDOM % ${#cards[@]}]}"
}

function calculate_hand_value {
    local hand=("$@")
    local total=0
    local aces=0
    for card in "${hand[@]}"; do
        value=${card_values[${card%[♠♥♦♣]}]}
        total=$((total + value))
        if [[ "${card%[♠♥♦♣]}" == "A" ]]; then
            aces=$((aces + 1))
        fi
    done
    while [[ $total -gt 21 && $aces -gt 0 ]]; do
        total=$((total - 10))
        aces=$((aces - 1))
    done
    echo $total
}

function show_hand {
    local owner="$1"
    shift
    local hand=("$@")
    slow_text "$owner's hand:" 0.05
    for card in "${hand[@]}"; do
        slow_text "$card" 0.1
    done
}

function place_bet {
    while true; do
        slow_text "You have $currency chips." 0.1
        read -p "Enter your bet: " bet
        if [[ "$bet" =~ ^[0-9]+$ && $bet -le $currency && $bet -gt 0 ]]; then
            echo $bet
            return
        else
            slow_text "Invalid bet. Please enter a valid amount." 0.1
        fi
    done
}

function game_loop {
    while [[ $currency -gt 0 ]]; do
        local bet=$(place_bet)

        dealer_hand=($(draw_card) $(draw_card))
        player_hand=($(draw_card) $(draw_card))

        while true; do
            echo
            show_hand "Dealer" "[Hidden]" "${dealer_hand[1]}"
            show_hand "Your" "${player_hand[@]}"
            player_total=$(calculate_hand_value "${player_hand[@]}")
            slow_text "Your total: $player_total" 0.1

            if [[ $player_total -gt 21 ]]; then
                slow_text "Bust! You lose your bet of $bet chips." 0.1
                currency=$((currency - bet))
                break
            fi

            echo
            echo "What would you like to do? (stand/hit/double)"
            read -p "Enter your choice: " choice

            case $choice in
                "stand")
                    break
                    ;;
                "hit")
                    new_card=$(draw_card)
                    player_hand+=("$new_card")
                    slow_text "You drew: $new_card" 0.1
                    ;;
                "double")
                    if [[ $bet -le $currency ]]; then
                        new_card=$(draw_card)
                        player_hand+=("$new_card")
                        slow_text "You doubled your bet to $((bet * 2)) and drew: $new_card" 0.1
                        bet=$((bet * 2))
                        break
                    else
                        slow_text "You don't have enough chips to double." 0.1
                    fi
                    ;;
                *)
                    slow_text "Invalid choice. Please choose stand, hit, or double." 0.1
                    ;;
            esac
        done

        if [[ $player_total -le 21 ]]; then
            slow_text "Dealer's turn..." 0.1
            dealer_total=$(calculate_hand_value "${dealer_hand[@]}")
            while [[ $dealer_total -lt 17 ]]; do
                new_card=$(draw_card)
                dealer_hand+=("$new_card")
                dealer_total=$(calculate_hand_value "${dealer_hand[@]}")
            done

            show_hand "Dealer" "${dealer_hand[@]}"
            slow_text "Dealer's total: $dealer_total" 0.1

            if [[ $dealer_total -gt 21 ]]; then
                slow_text "Dealer busts! You win $bet chips!" 0.1
                currency=$((currency + bet))
            elif [[ $dealer_total -gt $player_total ]]; then
                slow_text "Dealer wins! You lose your bet of $bet chips." 0.1
                currency=$((currency - bet))
            elif [[ $dealer_total -lt $player_total ]]; then
                slow_text "You win! You earn $bet chips!" 0.1
                currency=$((currency + bet))
            else
                slow_text "It's a tie! Your bet of $bet chips is returned." 0.1
            fi
        fi

        if [[ $currency -le 0 ]]; then
            slow_text "You're out of chips! The casino has kicked you out. Better luck next time!" 0.1
            exit 0
        fi

        echo
        read -p "Would you like to play again? (yes/no): " play_again
        if ! [[ "$play_again" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            slow_text "Thanks for playing! You leave with $currency chips. Goodbye!" 0.1
            exit 0
        fi
    done
}

function display_rules {
    slow_text "Welcome to Blackjack!" 0.1
    slow_text "Here are the rules of the game:" 0.1
    slow_text "1. The goal is to beat the dealer without going over 21." 0.05
    slow_text "2. Face cards are worth 10 points. Aces are 1 or 11." 0.05
    slow_text "3. Players start with two cards, as does the dealer." 0.05
    slow_text "4. Players can 'Hit', 'Stand', or 'Double' their bet." 0.05
    slow_text "5. Dealer must draw until 17 or higher." 0.05
    slow_text "6. Win by having a higher total than the dealer without exceeding 21." 0.05
    slow_text "7. Run out of chips, and you're out of the casino!" 0.1
    echo
}

function start_game {
    read -p "Would you like to hear the rules? (yes/no): " show_rules
    if [[ "$show_rules" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        display_rules
    else
        slow_text "Skipping rules. Let's get started!" 0.1
    fi

    read -p "Would you like to play Blackjack? (yes/no): " response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        game_loop
    else
        slow_text "Alright, maybe next time! Have a great day!" 0.1
    fi
}

start_game

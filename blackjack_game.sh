#!/bin/bash

cards=("2♠" "3♠" "4♠" "5♠" "6♠" "7♠" "8♠" "9♠" "10♠" "J♠" "Q♠" "K♠" "A♠"
       "2♥" "3♥" "4♥" "5♥" "6♥" "7♥" "8♥" "9♥" "10♥" "J♥" "Q♥" "K♥" "A♥"
       "2♦" "3♦" "4♦" "5♦" "6♦" "7♦" "8♦" "9♦" "10♦" "J♦" "Q♦" "K♦" "A♦"
       "2♣" "3♣" "4♣" "5♣" "6♣" "7♣" "8♣" "9♣" "10♣" "J♣" "Q♣" "K♣" "A♣")

declare -A card_values=( ["2"]=2 ["3"]=3 ["4"]=4 ["5"]=5 ["6"]=6 ["7"]=7 ["8"]=8 ["9"]=9 ["10"]=10 
                         ["J"]=10 ["Q"]=10 ["K"]=10 ["A"]=11 )

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

function game_loop {
    dealer_hand=($(draw_card) $(draw_card))
    player_hand=($(draw_card) $(draw_card))

    while true; do
        echo
        echo "Dealer's hand:"
        echo "Card 1: [Hidden]"
        echo "Card 2: ${dealer_hand[1]}"
        echo
        echo "Your hand: ${player_hand[*]}"
        player_total=$(calculate_hand_value "${player_hand[@]}")
        echo "Your total: $player_total"

        if [[ $player_total -gt 21 ]]; then
            echo "Bust! You lose!"
            return
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
                echo "You drew: $new_card"
                ;;
            "double")
                new_card=$(draw_card)
                player_hand+=("$new_card")
                echo "You doubled down and drew: $new_card"
                break
                ;;
            *)
                echo "Invalid choice. Please choose stand, hit, or double."
                ;;
        esac
    done

    echo
    echo "Dealer's turn..."
    dealer_total=$(calculate_hand_value "${dealer_hand[@]}")
    while [[ $dealer_total -lt 17 ]]; do
        new_card=$(draw_card)
        dealer_hand+=("$new_card")
        dealer_total=$(calculate_hand_value "${dealer_hand[@]}")
    done

    echo "Dealer's hand: ${dealer_hand[*]}"
    echo "Dealer's total: $dealer_total"

    if [[ $dealer_total -gt 21 ]]; then
        echo "Dealer busts! You win!"
    elif [[ $dealer_total -gt $player_total ]]; then
        echo "Dealer wins!"
    elif [[ $dealer_total -lt $player_total ]]; then
        echo "You win!"
    else
        echo "It's a tie!"
    fi
}

function display_rules {
    slow_text "Welcome to Blackjack!" 0.1
    slow_text "Here are the rules of the game:" 0.1
    slow_text "1. The goal of Blackjack is to beat the dealer's hand without going over 21." 0.05
    slow_text "2. Face cards (Kings, Queens, and Jacks) are worth 10 points." 0.05
    slow_text "3. Aces are worth 1 or 11 points, whichever is more favorable for your hand." 0.05
    slow_text "4. Each player starts with two cards, and the dealer also gets two cards." 0.05
    slow_text "5. Players can choose to:" 0.05
    slow_text "   - 'Hit': Take another card." 0.05
    slow_text "   - 'Stand': Keep their current total and end their turn." 0.05
    slow_text "6. If your hand goes over 21, you 'bust' and lose the round." 0.05
    slow_text "7. The dealer must draw cards until their total is 17 or higher." 0.05
    slow_text "8. Whoever has the highest total without going over 21 wins!" 0.05
    slow_text "Good luck and have fun!" 0.1
    echo
}

display_rules

read -p "Would you like to play Blackjack? (yes/no): " response

if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    game_loop
else
    slow_text "Alright, maybe next time! Have a great day!" 0.1
fi

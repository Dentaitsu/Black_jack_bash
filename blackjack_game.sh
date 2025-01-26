#!/bin/bash

# ---------------------------------------
# Deck of cards
# ---------------------------------------
cards=("2♠" "3♠" "4♠" "5♠" "6♠" "7♠" "8♠" "9♠" "10♠" "J♠" "Q♠" "K♠" "A♠"
       "2♥" "3♥" "4♥" "5♥" "6♥" "7♥" "8♥" "9♥" "10♥" "J♥" "Q♥" "K♥" "A♥"
       "2♦" "3♦" "4♦" "5♦" "6♦" "7♦" "8♦" "9♦" "10♦" "J♦" "Q♦" "K♦" "A♦"
       "2♣" "3♣" "4♣" "5♣" "6♣" "7♣" "8♣" "9♣" "10♣" "J♣" "Q♣" "K♣" "A♣")

declare -A card_values=( ["2"]=2 ["3"]=3 ["4"]=4 ["5"]=5 ["6"]=6 ["7"]=7 ["8"]=8 ["9"]=9 ["10"]=10 
                         ["J"]=10 ["Q"]=10 ["K"]=10 ["A"]=11 )

# ---------------------------------------
# Functions
# ---------------------------------------

# Slow text printer, for dramatic effect
function slow_text {
    local text="$1"
    local delay="${2:-0.05}"
    for ((i=0; i<${#text}; i++)); do
        echo -n "${text:i:1}"
        sleep "$delay"
    done
    echo
}

# Draw a random card from the deck array
function draw_card {
    echo "${cards[$RANDOM % ${#cards[@]}]}"
}

# Calculate the total value of a hand (array of cards).
# Aces can be 1 or 11, so if total > 21 and we have any Aces, subtract 10 for each Ace if needed.
function calculate_hand_value {
    local hand=("$@")
    local total=0
    local aces=0
    for card in "${hand[@]}"; do
        local value=${card_values[${card%[♠♥♦♣]}]}  # Strip the suit from the end to get the rank
        total=$((total + value))
        if [[ "${card%[♠♥♦♣]}" == "A" ]]; then
            aces=$((aces + 1))
        fi
    done

    # If total is over 21 and there are Aces counted as 11, reduce them to 1 by subtracting 10
    while [[ $total -gt 21 && $aces -gt 0 ]]; do
        total=$((total - 10))
        aces=$((aces - 1))
    done

    echo $total
}

# ---------------------------------------
# ASCII Art for Cards
# ---------------------------------------

# Print a single card's ASCII art with color:
#   - Spades (♠) and Clubs (♣) in white (bright white)
#   - Hearts (♥) and Diamonds (♦) in red
function print_card_art {
    local card="$1"
    # rank = everything except the last character (suit)
    local rank="${card%[♠♥♦♣]}"
    # suit = the last character
    local suit="${card: -1}"

    # Decide color based on suit
    # \e[97m = bright white; \e[31m = red; \e[0m = reset
    local color=""
    if [[ "$suit" == "♠" || "$suit" == "♣" ]]; then
        color="\e[97m"  # White for black suits
    else
        color="\e[31m"  # Red for hearts/diamonds
    fi

    # We handle rank spacing if rank is two digits ("10") vs. one digit/letter.
    # We'll keep a simple 7-character wide card.
    # E.g.:
    # ┌───────┐
    # | 10    |
    # |   ♥   |
    # |    10 |
    # └───────┘
    #
    # or
    #
    # ┌───────┐
    # | A     |
    # |   ♥   |
    # |     A |
    # └───────┘

    echo -e "${color}┌───────┐\e[0m"
    if [[ ${#rank} -eq 2 ]]; then
        # rank is two characters (i.e., 10)
        echo -e "${color}| ${rank}    |\e[0m"
    else
        # rank is one character
        echo -e "${color}| ${rank}     |\e[0m"
    fi
    echo -e "${color}|   ${suit}   |\e[0m"
    if [[ ${#rank} -eq 2 ]]; then
        echo -e "${color}|    ${rank} |\e[0m"
    else
        echo -e "${color}|     ${rank} |\e[0m"
    fi
    echo -e "${color}└───────┘\e[0m"
}

# A face-down ASCII card for the dealer's hidden card
function print_card_face_down {
    # No color needed, just a “mystery” back
    cat << EOF
┌───────┐
|       |
|  ???  |
|       |
└───────┘
EOF
}

# Show a single hand's cards in ASCII
function show_hand {
    local owner="$1"
    shift
    local hand=("$@")

    slow_text "$owner's hand:" 0.05
    for card in "${hand[@]}"; do
        print_card_art "$card"
        sleep 0.1
    done
}

# ---------------------------------------
# Main Game Logic
# ---------------------------------------

function game_loop {
    while true; do
        # Deal initial two cards to Dealer and Player
        dealer_hand=($(draw_card) $(draw_card))
        player_hand=($(draw_card) $(draw_card))

        # Player's turn
        while true; do
            echo
            slow_text "Dealer's hand:" 0.05
            # Show one hidden card, one revealed
            print_card_face_down
            print_card_art "${dealer_hand[1]}"

            echo
            show_hand "Your" "${player_hand[@]}"
            player_total=$(calculate_hand_value "${player_hand[@]}")
            slow_text "Your total: $player_total" 0.1

            # Check if player busts
            if [[ $player_total -gt 21 ]]; then
                slow_text "Bust! You lose this round." 0.1
                break
            fi

            echo
            echo "What would you like to do? (stand/hit)"
            read -p "Enter your choice: " choice

            case $choice in
                stand|Stand)
                    break
                    ;;
                hit|Hit)
                    new_card=$(draw_card)
                    player_hand+=("$new_card")
                    slow_text "You drew:" 0.1
                    print_card_art "$new_card"
                    ;;
                *)
                    slow_text "Invalid choice. Please choose stand or hit." 0.1
                    ;;
            esac
        done

        # Dealer's turn, only if player hasn't busted
        if [[ $player_total -le 21 ]]; then
            slow_text "Dealer's turn..." 0.1
            dealer_total=$(calculate_hand_value "${dealer_hand[@]}")

            # Dealer hits until total >= 17
            while [[ $dealer_total -lt 17 ]]; do
                new_card=$(draw_card)
                dealer_hand+=("$new_card")
                dealer_total=$(calculate_hand_value "${dealer_hand[@]}")
            done

            echo
            show_hand "Dealer" "${dealer_hand[@]}"
            slow_text "Dealer's total: $dealer_total" 0.1

            # Compare totals
            if [[ $dealer_total -gt 21 ]]; then
                slow_text "Dealer busts! You win this round!" 0.1
            elif [[ $dealer_total -gt $player_total ]]; then
                slow_text "Dealer wins this round!" 0.1
            elif [[ $dealer_total -lt $player_total ]]; then
                slow_text "You win this round!" 0.1
            else
                slow_text "It's a tie!" 0.1
            fi
        fi

        echo
        read -p "Would you like to play again? (yes/no): " play_again
        if ! [[ "$play_again" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            slow_text "Thanks for playing! Goodbye!" 0.1
            exit 0
        fi
    done
}

# Simple rules display
function display_rules {
    slow_text "Welcome to Blackjack!" 0.1
    slow_text "Here are the rules of the game:" 0.1
    slow_text "1. The goal is to beat the dealer without going over 21." 0.05
    slow_text "2. Face cards are worth 10 points. Aces can be 1 or 11." 0.05
    slow_text "3. Players start with two cards, as does the dealer." 0.05
    slow_text "4. Players can 'Hit' to take a card or 'Stand' to hold." 0.05
    slow_text "5. Dealer must draw until reaching 17 or higher." 0.05
    slow_text "6. Win by having a higher total than the dealer without exceeding 21." 0.05
    echo
}

# Start game
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

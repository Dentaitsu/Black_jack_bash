#!/bin/bash

cards=("2♠" "3♠" "4♠" "5♠" "6♠" "7♠" "8♠" "9♠" "10♠" "J♠" "Q♠" "K♠" "A♠"
       "2♥" "3♥" "4♥" "5♥" "6♥" "7♥" "8♥" "9♥" "10♥" "J♥" "Q♥" "K♥" "A♥"
       "2♦" "3♦" "4♦" "5♦" "6♦" "7♦" "8♦" "9♦" "10♦" "J♦" "Q♦" "K♦" "A♦"
       "2♣" "3♣" "4♣" "5♣" "6♣" "7♣" "8♣" "9♣" "10♣" "J♣" "Q♣" "K♣" "A♣")

function deal_cards {
    dealer_card1=${cards[$RANDOM % ${#cards[@]}]}
    dealer_card2=${cards[$RANDOM % ${#cards[@]}]}
    player_card1=${cards[$RANDOM % ${#cards[@]}]}
    player_card2=${cards[$RANDOM % ${#cards[@]}]}

    echo "Starting the game!"
    echo
    echo "Dealer's hand:"
    echo "Card 1: [Hidden]"
    echo "Card 2: $dealer_card2"
    echo
    echo "Your hand:"
    echo "Card 1: $player_card1"
    echo "Card 2: $player_card2"
    echo
    echo "Good luck!"
}

echo "Welcome to Blackjack!"
echo
echo "Here are the rules of the game:"
echo
echo "1. The goal of Blackjack is to beat the dealer's hand without going over 21."
echo "2. Face cards (Kings, Queens, and Jacks) are worth 10 points."
echo "3. Aces are worth 1 or 11 points, whichever is more favorable for your hand."
echo "4. Each player starts with two cards, and the dealer also gets two cards."
echo "5. Players can choose to:"
echo "   - 'Hit': Take another card."
echo "   - 'Stand': Keep their current total and end their turn."
echo "6. If your hand goes over 21, you 'bust' and lose the round."
echo "7. The dealer must draw cards until their total is 17 or higher."
echo "8. Whoever has the highest total without going over 21 wins!"
echo
echo "Good luck and have fun!"
echo

read -p "Would you like to play Blackjack? (yes/no): " response

if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    deal_cards
else
    echo "Alright, maybe next time! Have a great day!"
fi

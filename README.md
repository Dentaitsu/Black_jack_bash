# Black_jack_bash

Dieses Skript ist ein vereinfachtes Blackjack-Spiel in Bash. Es ermöglicht Ihnen, gegen den Computer (Dealer) in einer virtuellen Blackjack-Runde anzutreten, mit Karten-ASCII-Art, Farbcodierung für schwarze und rote Karten sowie grundlegenden Spielregeln.

Voraussetzungen

    Ein Unix-/Linux-System mit Bash
    Ausführbare Rechte für das Skript (z. B. via chmod +x blackjack.sh)

Installation und Ausführung

    Laden Sie die Datei blackjack.sh herunter oder klonen Sie das Repository.
    Geben Sie die Ausführungsrechte frei:

chmod +x blackjack.sh

Starten Sie das Spiel:

    ./blackjack.sh

    Folgen Sie den Anweisungen im Terminal.

Spielregeln (Kurzfassung)

    Ziel ist es, einen höheren Wert als der Dealer zu erreichen, ohne 21 zu überschreiten.
    Zahlkarten entsprechen ihrem aufgedruckten Wert. Bube (J), Dame (Q) und König (K) zählen jeweils 10, Ass (A) kann 1 oder 11 sein.
    Spieler und Dealer beginnen mit je zwei Karten. Der Spieler kann wählen, ob er weitere Karten ziehen („Hit“) oder stehen bleiben („Stand“) möchte.
    Der Dealer zieht Karten, bis er mindestens 17 erreicht.
    Wer näher an 21 ist, ohne diese zu überschreiten, gewinnt.
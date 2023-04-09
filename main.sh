#!/bin/bash


#############################
# Initialisation de ncurses
tput clear
tput civis
stty -echo
# Creation des variables globales du personnage principale
declare -i x=1
declare -i y=1
declare -i xmax=50
declare -i ymax=10
declare -i point=0
declare map=$(cat map.txt)


# Affichage du caractère initial
echo "$map"
tput cup $y $x
echo -e -n "\033[33mC\033[0m"
#############################

function move() {
    key=$1
    case $key in
        # Flèche gauche
        "D")
            local -i f=$(( (x - 1) + (y * xmax) ))
            if [ "${map:$f:1}" == "#" ]; then
                x=$x
            else
                if [ "${map:$f:1}" == "." ]; then
                    ((point++))
                    map="${map:0:f} ${map:f+1:500}"
                fi;
                ((x--))
            fi
            ;;
        # Flèche droite
        "C")
            local -i f=$(( (x + 1) + (y * xmax) ))
            if [ "${map:$f:1}" == "#" ]; then
                x=$x
            else
                ((x++))
            fi
            ;;
        # Flèche du bas
        "B")
            local -i f=$(( (y + 1) * xmax + x ))
            if [ "${map:$f:1}" == "#" ]; then
                y=$y
            else
                ((y++))
            fi
            ;;
        # Flèche du haut
        "A")
            local -i f=$(( (y - 1) * xmax + x ))
            if [ "${map:$f:1}" == "#" ]; then
                y=$y
            else
                ((y--))
            fi
            ;;
        # Autres touches ignorées
        *)
            ;;
    esac
    tput cup $y $x
    echo -e -n "\033[33mC\033[0m"
}


function main() {

    # Boucle principale
    while true; do
        # Récupération de la touche enfoncée
        read -rsn1 key
        if [[ "$key" == c ]]; then
            tput cnorm
            stty echo
            clear
            exit 0
        fi;
        clear
        echo "$map"
        move $key
    done

    # Restauration des paramètres du terminal
    tput cnorm
    stty echo
}

main


# -r : les entrées comme \n sont traitées littéralement plutôt que comme un retour à la ligne.
# -s : affiche pas l input
# -n1 : nbr de caractere souhaiter en input sans appuyer entrer
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
declare -i pointmax=125
declare -i xpoint=55
declare -i ypoint=1
declare -i posenemix=20
declare -i posenemiy=3
declare map=$(cat map.txt)

# Affichage du caractère initial
echo "$map"
tput cup $y $x
echo -e -n "\033[33mC\033[0m"
tput cup $posenemiy $posenemix
echo -e -n "o"
#############################

function first_enemie_deplacement() {
  local readonly direction=$((RANDOM % 4))
#   local readonly direction=1

  case $direction in
    "0") # Haut
        local -i f=$(( (posenemiy - 1) * xmax + posenemix ))
        if [ "${map:$f:1}" == "#" ]; then
            first_enemie_deplacement
        else
            posenemiy=$(expr $posenemiy - 1)
        fi
        return
    ;;
    "1") # Bas
        local -i f=$(( (posenemiy + 1) * xmax + posenemix ))
        if [ "${map:$f:1}" == "#" ]; then
            first_enemie_deplacement
        else
            posenemiy=$(expr $posenemiy + 1)
        fi
        return
    ;;
    "2") # Gauche
       local -i f=$(( (posenemix - 1) + (posenemiy * xmax) ))
        if [ "${map:$f:1}" == "#" ]; then
            first_enemie_deplacement
        else
            posenemix=$(expr $posenemix - 1)
        fi
        return
    ;;
    "3") # Droite
       local -i f=$(( (posenemix + 1) + (posenemiy * xmax) ))
        if [ "${map:$f:1}" == "#" ]; then
            first_enemie_deplacement
        else
            posenemix=$(expr $posenemix + 1)
        fi
        return
    ;;
    *)
        return
    ;;
    esac
    return
}

function move() {
    key=$1
    case $key in
        # Flèche gauche
        "a")
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
        "e")
            local -i f=$(( (x + 1) + (y * xmax) ))
            if [ "${map:$f:1}" == "#" ]; then
                x=$x
            else
                if [ "${map:$f:1}" == "." ]; then
                    ((point++))
                    map="${map:0:f} ${map:f+1:500}"
                fi;
                ((x++))
            fi
            ;;
        # Flèche du bas
        "s")
            local -i f=$(( (y + 1) * xmax + x ))
            if [ "${map:$f:1}" == "#" ]; then
                y=$y
            else
                if [ "${map:$f:1}" == "." ]; then
                    ((point++))
                    map="${map:0:f} ${map:f+1:500}"
                fi;
                ((y++))
            fi
            ;;
        # Flèche du haut
        "z")
            local -i f=$(( (y - 1) * xmax + x ))
            if [ "${map:$f:1}" == "#" ]; then
                y=$y
            else
                if [ "${map:$f:1}" == "." ]; then
                    ((point++))
                    map="${map:0:f} ${map:f+1:500}"
                fi;
                ((y--))
            fi
            ;;
        # Autres touches ignorées
        *)
            ;;
    esac
}

function print_point() {
    tput cup  $ypoint $xpoint ; echo -e -n "------------"
    tput cup  $((ypoint+1)) $xpoint ; echo -e "-  Points: -"
    if [[ $(echo -n "$point" | wc -c) -eq 1 ]]; then
        tput cup  $((ypoint+2)) $xpoint ; echo -e -n "-     $point    -"
    elif [[ $(echo -n "$point" | wc -c) -eq 2 ]]; then
        tput cup  $((ypoint+2)) $xpoint ; echo -e -n "-     $point   -"
    else
        tput cup  $((ypoint+2)) $xpoint ; echo -e -n "-     $point  -"
    fi;
    tput cup  $((ypoint+3)) $xpoint ; echo -e -n "------------"
}

function main() {

    while true; do
        read -rsn1 key
        if [[ "$key" == c ]]; then
            tput cnorm
            stty echo
            clear
            exit 0
        fi;
        clear
        echo "$map"
        print_point
        move $key
        first_enemie_deplacement
        tput cup $y $x ; echo -e -n "\033[33mC\033[0m"
        tput cup $posenemiy $posenemix ; echo "o"
        # sleep 1

    done

    # Restauration des paramètres du terminal
    tput cnorm
    stty echo
}

main


# -r : les entrées comme \n sont traitées littéralement plutôt que comme un retour à la ligne.
# -s : affiche pas l input
# -n1 : nbr de caractere souhaiter en input sans appuyer entrer
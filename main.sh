#!/bin/bash





##### check ncurse

#!/bin/bash

if ! ldconfig -p | grep -q libncurses; then
    echo "Can we install ncurses ? y or n"
    read -rsn1 r
    if [ "$r" = "n" ]; then
        exit 0
    fi;
    if [[ -n $(command -v apt-get) ]]; then
        sudo apt-get install libncurses5-dev libncursesw5-dev
    elif [[ -n $(command -v yum) ]]; then
        sudo yum install ncurses-devel
    elif [[ -n $(command -v pacman) ]]; then
        sudo pacman -S ncurses
    else
        echo "Cannot install ncurses. Package manager not found."
        exit 1
    fi
else
    clear
    echo "Ncurses is already installed, lets go!" ; sleep 2 ; clear
fi





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
declare -i pointmax=124
declare -i xpoint=55
declare -i ypoint=1
declare -i posenemix=20
declare -i posenemiy=3
declare end=false
declare -i win=0
declare -i lose=0
declare map=$(cat map.txt)
declare -i menu=-1

################################

OPTIONS=("PLAY" "LEAVE")

# Affichage du caractère initial
# echo "$map"
# tput cup $y $x
# echo -e -n "\033[33mC\033[0m"
# tput cup $posenemiy $posenemix
# echo -e -n "o"
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

function end_condition() {

    if [[ $point -gt $pointmax ]]; then
        win=1
    fi;
    if [ "$x" = "$posenemix" ] && [ "$y" = "$posenemiy" ] ; then
        lose=1
    fi;
}

function end_screen() {
    if [ $win -eq "1" ]; then
        clear
        local nx=0
        local ny=0
        tput cup $ny $nx
        echo -n "*****************************"
        tput cup $((ny+1)) $nx
        echo -n "*                           *"
        tput cup $((ny+2)) $nx
        echo -n "*           WIN             *"
        tput cup $((ny+3)) $nx
        echo -n "*                           *"
        tput cup $((ny+4)) $nx
        echo -n "*****************************"
        tput cup $((ny+5)) $nx
        echo -e "Do you want to play again?\n\tIf yes write y\n\tElse write n"
        tput cup $((ny+8)) $nx
        read -rsn1 response
        if [ "$response" = "y" ]; then
            tput cnorm
            stty echo
            exec bash "$0" "$@"
        elif [ "$response" = "n" ]; then
            tput cnorm
            stty echo
            clear
            exit 0
        fi;
    elif [ $lose -eq "1" ]; then
        clear
        local nx=0
        local ny=0
        tput cup $ny $nx
        echo -n "*****************************"
        tput cup $((ny+1)) $nx
        echo -n "*                           *"
        tput cup $((ny+2)) $nx
        echo -n "*          LOSE             *"
        tput cup $((ny+3)) $nx
        echo -n "*                           *"
        tput cup $((ny+4)) $nx
        echo -n "*****************************"
        tput cup $((ny+5)) $nx
        echo -e "Do you want to play again?\n\tIf yes write y\n\tElse write n"
        tput cup $((ny+8)) $nx
        read -rsn1 response
        if [ "$response" = "y" ]; then
            tput cnorm
            stty echo
            exec bash "$0" "$@"
        elif [ "$response" = "n" ]; then
            tput cnorm
            stty echo
            clear
            exit 0
        fi;
    fi;
}

function print_menu() {

    select=0
    local -i yp=10
    while true; do
        echo -e "\033[4m"
            tput cup 5 0
        echo "Click on 1 For Normal Execution and 2 for Error Execution and press a to confirm"
            tput cup 7 0
        echo "Click on c to exit"
        echo -e "\033[0m"
        # "#@" etant le nombre d'arg donner a un script ou a une fonction
        for (( i=0; $i<${#OPTIONS[@]}; i++ )); do
            tput cup $yp 2
            if [ "$i" = "$select" ]; then
                echo -e "\e[1m\e[7m${OPTIONS[$i]} \e[0m"
            else
                echo "${OPTIONS[$i]}"
            fi
            ((yp+=2))
        done
        read -s -n 1 key
        if [[ "$key" == "c" ]]; then
            clean_dir
            tput cnorm
            stty echo
            clear
            break
        fi;
        case "$key" in
            "1") select=0 ; clear ;;
            "2") select=1 ; clear ;;
            "a")    if [ "$select" = "1" ]; then
                        tput cnorm
                        stty echo
                        clear
                        exit 0
                        exit 0;
                    else
                        return 0
                    fi;
                ;;
            *) ;;
        esac
        yp=10
    done
}

function main() {

    clear
    print_menu

    while [ "$end" = false ]; do
         end_condition
        if [ "$win" = "$lose" ] ; then
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
        else
            end_screen
        fi;
        # echo "---- $(end_screen)"
    done
    # Restauration des paramètres du terminal
    tput cnorm
    stty echo
}

main
# print_menu

# -r : les entrées comme \n sont traitées littéralement plutôt que comme un retour à la ligne.
# -s : affiche pas l input
# -n1 : nbr de caractere souhaiter en input sans appuyer entrer
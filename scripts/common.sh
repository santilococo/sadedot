#!/usr/bin/env bash

displayDialogBox() {
    case $dialogBox in
        whiptail)
            if [ "$1" = "--menu" ]; then
                useWhiptailMenu "$@"
            else
                if [ "$1" = "--infobox" ] && tty | grep -q "/dev/pts"; then
                    local TERM=ansi
                fi
                useWhiptail "$@"
            fi
            ;;
        dialog)
            if [ "$1" = "--menu" ]; then
                useDialogMenu "$@"
            else
                useDialog "$@"
            fi
            ;;
        plain)
            if [ "$1" = "--menu" ]; then
                usePlainTextMenu "$@"
            else
                usePlainText "$@"
            fi
            ;;
        ?)
            echo "Unknown dialogBox variable" >&2
            exit 1
            ;;
    esac
}

useDialog() {
    str=$(getLastArgument "$@"); inputbox=false
    if [ "$str" = "VALUES" ]; then
        argc="$#"; i=1
        for item in "$@"; do
            if [ $i -eq $((argc-1)) ]; then
                str="$item"
                break
            fi
            [ "$item" = "--inputbox" ] && inputbox=true
            ((i++))
        done
    fi
    width=$(calcWidthDialog "$str")
    height=$(calcHeightDialog "$str")
    if [ $inputbox = true ]; then
        width=$((width+15))
        height=$((height+2))
    fi
    formatOptions "$@"
    if [ "$found" = false ]; then
        dialog "$@" ${height} ${width}
    else
        dialog "${options[@]}"
    fi
}

useWhiptail() {
    str=$(getLastArgument "$@"); inputbox=false; infobox=false
    if [ "$str" = "VALUES" ]; then
        argc="$#"; i=1
        for item in "$@"; do
            if [ $i -eq $((argc-1)) ]; then
                str="$item"
                break
            fi
            [ "$item" = "--inputbox" ] && inputbox=true
            [ "$item" = "--infobox" ] && infobox=true
            ((i++))
        done
    fi
    width=$(calcWidthWhiptail "$str")
    height=$(calcHeightWhiptail "$str")
    [ $inputbox = true ] && [ $width -lt 30 ] && width=$((width+5))
    [ $infobox = true ] && height=$((height-1))
    formatOptions "$@"
    if [ "$found" = false ]; then
        height=0; width=0
        whiptail "$@" ${height} ${width}
    else
        whiptail "${options[@]}"
    fi
}

printLine() {
    printf '\n\n%s' "----------------------------------------"
}

usePlainText() {
    clear
    inputbox=false; infobox=false; msgbox=false; passwordbox=false; yesno=false
    for item in "$@"; do
        case $item in
            --title) shift && shift ;;
            --inputbox) inputbox=true ;;
            --infobox) infobox=true ;;
            --msgbox) msgbox=true ;;
            --passwordbox) passwordbox=true ;;
            --yesno) yesno=true ;;
        esac
    done
    tput bold
    printf "${2:2}\n"
    tput sgr0
    if [ $inputbox = true ]; then
        printLine && printf "\n"
        read -r readVar
        printf "$readVar" 1>&2
    elif [ $passwordbox = true ]; then
        printLine && printf "\n"
        read -r -s readVar
        printf "$readVar" 1>&2
    elif [ $yesno = true ]; then
        printLine
        printf '\n%s' "[y/n] "
        read -n 1 -r -s readVar
        while echo "$readVar" | grep -vqE '[yYnN]'; do
            printf "\033[A"
            printf '\n%s' "You need to type 'y' or 'n'"
            printf '\n%s' "[y/n] "
            read -n 1 -r -s readVar
        done
        [[ "$readVar" =~ ^[Yy]$ ]] && return 0 || return 1
    elif [ $msgbox = true ]; then
        printLine
        printf '\n%s' "Press a key to continue... "
        read -n 1 -r -s
    fi
}

usePlainTextMenu() {
    clear
    tput bold
    shift; printf "${1:2}\n"; shift; shift
    tput sgr0
    local i=1; for item in "$@"; do
        echo "$item" | grep -qE '[0-9]+' && continue
        printf '%s\n' "$i) $item"
        ((i++))
    done
    printLine
    printf '\n%s' "[1..$((i-1))] "
    read -n ${#i} -r readVar
    while echo "$readVar" | grep -vqE '[0-9]+' || [[ $readVar -le 0 || $readVar -ge $i ]]; do
        printf "\033[A"
        printf '\n%s' "You need to choose a number between 1 and $((i-1))"
        printf '\n%s' "[1..$((i-1))] "
        read -n 1 -r -s readVar
    done
    printf "\n"
    printf "$readVar" 1>&2
}

getLastArgument() {
    local i=0
    for i; do :; done
    echo "$i"
}

formatOptions() {
    options=(); found=false
    for item in "$@"; do
        if [ "$item" = "VALUES" ]; then
            options+=("${height}")
            options+=("${width}")
            found=true
            continue
        fi

        options+=("${item}")
    done
}

useWhiptailMenu() {
    height=0; width=0
    formatOptions "$@"
    whiptail --notags "${options[@]}"
}

useDialogMenu() {
    height=9; width=60
    formatOptions "$@"
    dialog --no-tags "${options[@]}"
}

calcWidthWhiptail() {
    width=$(echo "$1" | wc -c)
    [ $width -gt 60 ] && echo 60 || echo $((width+2))
}

calcWidthDialog() {
    count=1; found=false; option=1
    while IFS= read -r -N 1 c; do
        if [[ "$c" == $'\n' ]]; then
            [ $count -ge $option ] && option=$count
            found=true
            count=-1
        fi
        ((count++))
    done < <(echo -ne "$1")
    [ $option -ge "$count" ] && count=option
    [ $count -gt 60 ] && echo 60 || echo $((count+4))
}

calcHeight() {
    newlines=$(echo -ne "$1" | grep -c $'\n')
    height=$(echo "${#1}" "$newlines" | awk '{
        x = (($1 - $2 + ($2 * 60)) / 60)
        printf "%d", (x == int(x)) ? x : int(x) + 1
    }')
}

calcHeightWhiptail() {
    calcHeight "$@"
    echo $((6+height))
}

calcHeightDialog() {
    calcHeight "$@"
    echo $((4+height))
}

checkCancel() {
    [ $? -eq 0 ] && return 1
    displayDialogBox --msgbox "$1" VALUES
    return 0
}

setDialogBox() {
    export dialogBox=${1}
}

getDialogBox() {
    echo "$dialogBox"
}

setLogToFile() {
    export logToFile=${1}
    export logFolder=${2}
}

debug() {
    if [[ -n $logToFile && $logToFile = true ]]; then
        tee -a "$logFolder/sadedot.log" > /dev/null
    else
        tee > /dev/null
    fi
}

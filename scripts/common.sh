#!/usr/bin/env bash

displayDialogBox() {
    case $dialogBox in
        whiptail) useWhiptail "$@" ;;
        dialog) useDialog "$@" ;;
        plain) usePlainText "$@" ;;
        ?) echo "Unknown dialogBox variable" >&2 && exit 1 ;;
    esac
}

useDialog() {
    if [[ "$1" == "--checklist" || "$1" == "--menu" ]]; then
        useDialogListOrMenu "$@"
        exit
    fi
    inputbox=false; passwordbox=false; infobox=false
    str=$(getLastArgument "$@")
    if [ "$str" = "VALUES" ]; then
        argc="$#"; i=1
        for item in "$@"; do
            if [ $i -eq $((argc-1)) ]; then
                str="$item"
            fi
            [ "$item" = "--inputbox" ] && inputbox=true
            [ "$item" = "--passwordbox" ] && passwordbox=true
            [ "$item" = "--infobox" ] && infobox=true
            ((i++))
        done
    fi
    width=$(calcWidthDialog "$str")
    height=$(calcHeightDialog "$str" "$width")
    if [ $inputbox = true ] || [ $passwordbox = true ]; then
        width=$((width+15))
        height=$((height+2))
    fi
    [ $infobox = true ] && height=$((height-2))
    formatOptions "$@"
    if [ "$found" = false ]; then
        dialog "$@" ${height} ${width}
    else
        dialog "${options[@]}"
    fi
}

useWhiptail() {
    if [[ "$1" == "--checklist" || "$1" == "--menu" ]]; then
        useWhiptailListOrMenu "$@"
        exit
    fi
    [ "$1" = "--infobox" ] && tty | grep -q "/dev/pts" && local TERM=ansi
    inputbox=false; infobox=false
    str=$(getLastArgument "$@")
    if [ "$str" = "VALUES" ]; then
        argc="$#"; i=1
        for item in "$@"; do
            if [ $i -eq $((argc-1)) ]; then
                str="$item"
            fi
            [ "$item" = "--inputbox" ] && inputbox=true
            [ "$item" = "--infobox" ] && infobox=true
            ((i++))
        done
    fi
    width=$(calcWidthWhiptail "$str")
    height=$(calcHeightWhiptail "$str")
    [ $inputbox = true ] && [ "$width" -lt 30 ] && width=$((width+5))
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
    if [ "$1" = "--menu" ]; then
        usePlainTextMenu "$@"
        exit
    fi
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
    printf '%s\n' "${2:2}"
    tput sgr0
    if [ $inputbox = true ]; then
        printLine && printf "\n"
        read -r readVar
        printf '%s' "$readVar" 1>&2
    elif [ $passwordbox = true ]; then
        printLine && printf "\n"
        read -r -s readVar
        printf '%s' "$readVar" 1>&2
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
    shift; printf '%s\n' "${1:2}"; shift; shift
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
    printf '%s' "$readVar" 1>&2
}

getLastArgument() {
    local i=0
    for i; do :; done
    echo "$i"
}

formatOptions() {
    options=(); found=false; isListOrMenu=false
    [[ "$1" == "--checklist" || "$1" == "--menu" ]] && isListOrMenu=true
    for item in "$@"; do
        if [ "$item" = "VALUES" ]; then
            options+=("${height}")
            options+=("${width}")
            [ $isListOrMenu = true ] && options+=("${listHeight}")
            found=true
            continue
        fi

        options+=("${item}")
    done
}

getListOrMenuOptions() {
    maxLen=0; i=1; j=1; notFound=true; msgLen=-1; argsQty=0; isList=false; height=0
    [ "$1" = "--checklist" ] && isList=true
    for item in "$@"; do
        [ "${item:0:2}" = "--" ] && continue
        [ $i -eq $j ] && [ $msgLen = -1 ] && msgLen=${#item}
        if [ $notFound = true ]; then
            [[ "${item}" == "VALUES" ]] && ((i+=3))
            [[ "${item}" == +([0-9]) ]] && ((i++))
            [ "$i" -le 3 ] && continue
        fi
        notFound=false
        if [ $((j % 3)) -eq 0 ]; then
            strLen=${#item}
            [ "$strLen" -gt $maxLen ] && maxLen=$strLen
            ((argsQty++))
            [ $isList = false ] && ((j++))
        fi
        ((j++))
    done
    if [ "$msgLen" -gt 52 ]; then
        height=$(echo "$msgLen" | awk '{
            x = $1 / 57
            printf "%d", (x == int(x)) ? x : int(x) + 1 
        }')
        msgLen=52
    fi
    maxLen=$((maxLen+15)) && [ "$maxLen" -ge "$msgLen" ] || maxLen=$((msgLen+3))
    [ "$dialogBox" = "whiptail" ] && heightOffset=9 || heightOffset=8
    argsQty=$((argsQty+heightOffset)) && [ "$argsQty" -le 20 ] || argsQty=20
    listHeight=$((argsQty-heightOffset)) && [ "$argsQty" -ge 10 ] || listHeight=$((argsQty-heightOffset))
    height=$((argsQty+height)); width=$maxLen
    formatOptions "$@"
}

useDialogListOrMenu() {
    getListOrMenuOptions "$@"
    dialog --no-tags "${options[@]}"
}

useWhiptailListOrMenu() {
    getListOrMenuOptions "$@"
    whiptail --notags --separate-output "${options[@]}"
}

calcWidthWhiptail() {
    width=${#1}
    [ "$width" -gt 60 ] && echo 60 || echo $((width+2))
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
    [ $((count)) -gt 60 ] && echo 60 || echo $((count+4))
}

calcHeightWhiptail() {
    newlines=$(echo -ne "$1" | grep -c $'\n')
    height=$(echo "${#1}" "$newlines" | awk '{
        x = (($1 - $2 + ($2 * 60)) / 60)
        printf "%d", (x == int(x)) ? x : int(x) + 1
    }')
    echo $((6+height))
}

calcHeightDialog() {
    newlines=$(echo -ne "$1" | grep -c $'\n')
    strlen=$((${#1}-1))
    width=$(($2-4))
    height=$(echo "$strlen" "$((newlines-1))" "$width" | awk '{
        z = ($1 - $2) / $3
        y = (z == int(z)) ? int(z) : int(z) + 1
        n = ($2 / 1.3)
        x = y + ((n - int(n) < 0.5) ? int(n) : int(n) + 1)
        printf "%d", x
    }')
    echo $((5+height))
}

checkCancel() {
    [ $? -eq 0 ] && return 1
    displayDialogBox --msgbox "\n$1" VALUES
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

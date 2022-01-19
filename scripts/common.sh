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
    if [ $inputbox = true ]; then
        width=$((width+15))
    fi
    if [ $infobox = true ]; then
        height=$((height-1))
    fi
    formatOptions "$@"
    if [ "$found" = false ]; then
        height=0; width=0
        whiptail "$@" ${height} ${width}
    else
        whiptail "${options[@]}"
    fi
}

usePlainText() {
    clear
    inputbox=false; infobox=false; passwordbox=false; yesno=false
    for item in "$@"; do
        case $item in
            --title) shift && shift ;;
            --inputbox) inputbox=true ;;
            --infobox) infobox=true ;;
            --passwordbox) passwordbox=true ;;
            --yesno) yesno=true ;;
        esac
    done
    printf "$2\n"
    if [ $inputbox = true ]; then
        read -r readVar
        printf "$readVar" 1>&2
    elif [ $passwordbox = true ]; then
        read -r -s readVar
        printf "$readVar" 1>&2
    elif [ $yesno = true ]; then
        printf '\n%s' "[y/n] "
        read -n 1 -r -s readVar
        return $([[ "$readVar" =~ ^[Yy]$ ]])
    fi
}

usePlainTextMenu() {
    clear
    menuOptions=(); shift
    printf "$1\n"
    shift; shift
    local i=1; for item in "$@"; do
        echo "$item" | grep -qE '[0-9]+' && continue
        printf '%s\n' "$i) $item"
        ((i++))
    done
    printf '\n%s' "[1..$((i-1))] "
    read -n 1 -r -s readVar
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
    whiptail "${options[@]}"
}

useDialogMenu() {
    height=9; width=60
    formatOptions "$@"
    dialog "${options[@]}"
}

calcWidthWhiptail() {
    width=$(echo "$1" | wc -c)
    echo $((width+8))
}

calcWidthDialog() {
    str=$1; count=1; found=false; option=1
    for (( i = 0; i < ${#str}; i++ )); do
        if [ "${str:$i:1}" = '\' ] && [ "${str:$((i+1)):1}" = 'n' ]; then
            if [ $count -ge $option ]; then
                option=$count
            fi
            found=true
            count=-1
        fi
        ((count++))
    done

    if [ $found = false ]; then
        echo $((count+8))
    else
        echo $option
    fi
}

calcHeightWhiptail() {
    newlines=$(printf "$1" | grep -c $'\n')
    chars=$(echo "$1" | wc -c)
    height=$(echo "$chars" "$newlines" | awk '{
        x = (($1 - $2 + ($2 * 60)) / 60)
        printf "%d", (x == int(x)) ? x : int(x) + 1
    }')
    echo $((6+height))
}

calcHeightDialog() {
    newlines=$(printf "$1" | grep -c $'\n')
    chars=$(echo "$1" | wc -c)
    height=$(echo "$chars" "$newlines" | awk '{
        x = (($1 - $2 + ($2 * 60)) / 60)
        printf "%d", (x == int(x)) ? x : int(x) + 1
    }')
    echo $((4+height))
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

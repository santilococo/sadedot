#!/usr/bin/env bash

displayDialogBox() {
    case $dialogBox in
        whiptail)
            if [ "$1" = "--menu" ]; then
                useWhiptailMenu "$@"
            else
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
        ?)
            echo "Unknown dialogBox variable" >&2
            exit 1
            ;;
    esac
}

useDialog() {
    str="${@: -1}"; inputbox=false
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
    if [ $found = false ]; then
        dialog "$@" ${height} ${width}
    else
        dialog "${options[@]}"
    fi
}

useWhiptail() {
    str="${@: -1}"; inputbox=false; infobox=false
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
    if [ $found = false ]; then
        height=0; width=0
        whiptail "$@" ${height} ${width}
    else
        whiptail "${options[@]}"
    fi
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

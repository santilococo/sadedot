#!/bin/sh

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
    dialog "$@" 9 60
}

useWhiptail() {
    str="${@: -1}"
    if [ "$str" = "VALUES" ]; then
        argc="$#"; i=1
        for item in "$@"; do
            if [ $i -eq $((${argc}-1)) ]; then
                str="$item"
                break
            fi
            ((i++))
        done
    fi
    width=$(calcWidth "$str")
    height=$(calcHeight "$str")
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

calcWidth() {
    width=$(echo "$1" | wc -c)
    echo $((${width}+8))
}

calcHeight() {
    newlines=$(printf "$1" | grep -c $'\n')
    chars=$(echo "$1" | wc -c)
    height=$(echo "$chars" "$newlines" | awk '{
        x = (($1 - $2 + ($2 * 60)) / 60)
        printf "%d", (x == int(x)) ? x : int(x) + 1
    }')
    echo $((6+${height}))
}

setDialogBox() {
    export dialogBox=${1}
}
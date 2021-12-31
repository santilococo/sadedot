#!/bin/sh

displayDialogBox() {
    case $dialogBox in
        whiptail) 
            useWhiptail "$@"
            ;;
        dialog)
            useDialog "$@"
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
    str=$(echo "$@" | grep -oP '(?<=").*?(?=")')
    width=$(calcWidth "$str")
    height=$(calcHeight "$str")
    whiptail "$@" ${height} ${width}
}

calcWidth() {
    width=$(echo "$str" | wc -c)
    echo $((${width}+8))
}

calcHeight() {
    newlines=$(printf "$str" | grep -c $'\n')
    chars=$(echo "$str" | wc -c)
    height=$(echo "$chars" "$newlines" | awk '{
        x = (($1 - $2 + ($2 * 60)) / 60)
        printf "%d", (x == int(x)) ? x : int(x) + 1
    }')
    echo $((5+${height}))
}

setDialogBox() {
    export dialogBox=${1}
}
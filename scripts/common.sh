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
    whiptail "$@" 0 0
}

calcWidthAndRun() {
    width=$(echo "$@" | grep -oP '(?<=").*?(?=")' | wc -c)
    comm=$(echo "$@" | sed "s/WIDTH/$((${width}+8))/g")
    if [[ $comm != *"3>&1 1>&2 2>&3" ]]; then
        comm="${comm} 3>&1 1>&2 2>&3"
    fi
    commOutput=$(eval $comm)
    exitStatus=$?
    [ ! -z $commOutput ] && echo $commOutput
    return $exitStatus
}

calcHeightAndRun() {
    str=$(echo "$@" | grep -oP '(?<=").*?(?=")')
    newlines=$(printf "$str" | grep -c $'\n')
    chars=$(echo "$str" | wc -c)
    height=$(echo "$chars" "$newlines" | awk '{
        x = (($1 - $2 + ($2 * 60)) / 60)
        printf "%d", (x == int(x)) ? x : int(x) + 1
    }')
    comm=$(echo "$@" | sed "s/HEIGHT/$((5+$height))/g")
    if [[ $comm != *"3>&1 1>&2 2>&3" ]]; then
        toRun="${comm} 3>&1 1>&2 2>&3"
    fi
    commOutput=$(eval $comm)
    exitStatus=$?
    [ ! -z $commOutput ] && echo $commOutput
    return $exitStatus
}

setDialogBox() {
    export dialogBox=${1}
}
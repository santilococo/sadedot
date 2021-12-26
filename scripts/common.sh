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

setDialogBox() {
    export dialogBox=${1}
}
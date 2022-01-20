#!/usr/bin/env bash

usage() {
  cat << EOF
usage: ${0##*/} [command]
    -h | --help         Print this help message.
    -d | --dialog       Use dialog.
    -t | --text         Print plain text to stdout (without dialog or whiptail).
    -l | --log          Log to sadedot.log file.
    -p | --packages     Run scripts/install.sh at the end of this script.
EOF
}

checkParameters() {
    while [ -n "$1" ]; do
        case $1 in
            -h | --help)
                usage
                exit 0
                ;;
            -d | --dialog)
                checkForDependencies "dialog"
                setDialogBox "dialog"
                ;;
            -t | --text)
                setDialogBox "plain"
                ;;
            -l | --log)
                checkForDependencies "libnewt"
                setDialogBox "whiptail"
                setLogToFile true "$(pwd -P)"
                ;;
            -p | --packages) 
                runUserScripts=true
                ;;
            *)
                printf '%s: invalid option %s\n' "${0##*/}" "$1"
                exit 1
                ;;
        esac
        shift
    done

    if [ -z "$(getDialogBox)" ]; then
        checkForDependencies "libnewt"
        setDialogBox "whiptail"
    fi
}

getGitconfigData() {
    displayDialogBox --yesno "Would you like to set up gitconfig?" || return

    displayDialogBox --msgbox "Now, I will ask you for data to set up gitconfig personal account."
    gitPersonalName=$(displayDialogBox --inputbox "Enter a name." VALUES 3>&1 1>&2 2>&3)
    gitPersonalMail=$(displayDialogBox --inputbox "Enter an e-mail." VALUES 3>&1 1>&2 2>&3)

    while true; do
        displayDialogBox --yesno "Please confirm that the data you entered is correct:\n\n - Name: ${gitPersonalName}\n - E-mail: ${gitPersonalMail}" && break
        gitPersonalName=$(displayDialogBox --inputbox "Enter a name." VALUES 3>&1 1>&2 2>&3)
        gitPersonalMail=$(displayDialogBox --inputbox "Enter an e-mail." VALUES 3>&1 1>&2 2>&3)
    done
    
    displayDialogBox --yesno "Would you like to set up a work account?"
    if [ $? -eq 1 ]; then
        sed -e "s/PERSONAL_NAME/$gitPersonalName/g" -e "s/PERSONAL_MAIL/$gitPersonalMail/g" ./templates/.gitconfig-notwork > ./dotfiles/.gitconfig
        return
    fi

    gitWorkPath=$(displayDialogBox --inputbox "Enter an absolute folder path where you would like to use the work account." VALUES 3>&1 1>&2 2>&3)
    mkdir -p "$gitWorkPath"
    while [[ ! -d $gitWorkPath ]]; do
        gitWorkPath=$(displayDialogBox --inputbox "Path isn't valid. Please try again" VALUES 3>&1 1>&2 2>&3)
    done
    gitWorkName=$(displayDialogBox --inputbox "Enter a name." VALUES 3>&1 1>&2 2>&3)
    gitWorkMail=$(displayDialogBox --inputbox "Enter an e-mail." VALUES 3>&1 1>&2 2>&3)

    while true; do
        displayDialogBox --yesno "Please confirm that the data you entered is correct:\n\n - Name: ${gitWorkName}\n - E-mail: ${gitWorkMail}" && break
        gitWorkName=$(displayDialogBox --inputbox "Enter a name." VALUES 3>&1 1>&2 2>&3)
        gitWorkMail=$(displayDialogBox --inputbox "Enter an e-mail." VALUES 3>&1 1>&2 2>&3)
    done

    sed -e "s/PERSONAL_NAME/$gitPersonalName/g" -e "s/PERSONAL_MAIL/$gitPersonalMail/g" -e "s|WORK_PATH|${gitWorkPath}|g" ./templates/.gitconfig > ./dotfiles/.gitconfig
    sed -e "s/WORK_NAME/$gitWorkName/g" -e "s/WORK_MAIL/$gitWorkMail/g" ./templates/.gitconfig-work > ./dotfiles/.gitconfig-work
}

checkForDependencies() {
    comm=$1 && [ "$1" = "libnewt" ] && comm=whiptail

    command -v "${comm}" &> /dev/null
    if [ $? -eq 1 ]; then
        unameOutput=$(uname -a | grep "arch")
        if [ -f "/etc/arch-release" ] || [ "$unameOutput" -eq 0 ]; then
            sudo pacman --noconfirm --needed -Sy "${1}"
            if [ $? -eq 1 ]; then
                echo "Couldn't install ${1}." >&2
                exit 1
            fi

            return
        fi

        setDialogBox "plain"
    fi
}

startRice() {
    displayDialogBox --title "sadedot" --msgbox "Hi! This script will auto install my dotfiles."
    getGitconfigData
    source scripts/linkFiles.sh
    if [[ -n $runUserScripts && $runUserScripts = true ]]; then
        lastFolder=$(pwd -P)
        cd .. || { echo "Couldn't cd into parent folder." 1>&2 && exit 1; }
        for script in $(find -H scripts -type f); do
            source "$script"
        done
        cd "$lastFolder" || { echo "Couldn't cd into '$lastFolder'." 1>&2 && exit 1; }
    fi
    displayDialogBox --title "sadedot" --msgbox "All done! Enjoy..."
}

runScript() {
    lastFolder=$(pwd -P)
    sadedotFolder=$(pwd -P | awk '{ sub(/sadedot.*/, "sadedot"); print }')
    cd "$sadedotFolder" || { echo "Couldn't cd into '$sadedotFolder'." 1>&2 && exit 1; }

    source scripts/common.sh
    checkParameters "$@"
    clear

    startRice

    clear
    cd "$lastFolder" || { echo "Couldn't cd into '$lastFolder'." 1>&2 && exit 1; }
}

runScript "$@"

#!/usr/bin/env bash

usage() {
  cat << EOF
usage: ${0##*/} [command]
    -h | --help         Print this help message.
    -w | --whiptail     Use whiptail.
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
            -w | --whiptail)
                checkForDependencies "libnewt" && setDialogBox "whiptail"
                ;;
            -t | --text)
                setDialogBox "plain"
                ;;
            -l | --log)
                checkForDependencies "dialog" && setDialogBox "dialog"
                setLogToFile true "$(pwd -P)"
                ;;
            -p | --packages)
                userScriptsFlag=true
                ;;
            *)
                printf '%s: invalid option %s\n' "${0##*/}" "$1"
                exit 1
                ;;
        esac
        shift
    done

    if [ -z "$(getDialogBox)" ]; then
        checkForDependencies "dialog" && setDialogBox "dialog"
    fi
}

getGitconfigData() {
    displayDialogBox --yesno "\nWould you like to set up gitconfig?" || return

    displayDialogBox --msgbox "\nNow, I will ask you for data to set up gitconfig personal account."
    gitPersonalName=$(displayDialogBox --inputbox "\nEnter a name." VALUES 3>&1 1>&2 2>&3)
    checkCancel "You must enter a name." && return
    gitPersonalMail=$(displayDialogBox --inputbox "\nEnter an e-mail." VALUES 3>&1 1>&2 2>&3)
    checkCancel "You must enter an e-mail." && return

    while true; do
        msg="\nPlease confirm that the data you entered is correct:\n\n -"
        msg="${msg} Name: ${gitPersonalName}\n - E-mail: ${gitPersonalMail}"
        displayDialogBox --yesno "$msg" && break
        gitPersonalName=$(displayDialogBox --inputbox "\nEnter a name." VALUES 3>&1 1>&2 2>&3)
        checkCancel "You must enter a name." && return
        gitPersonalMail=$(displayDialogBox --inputbox "\nEnter an e-mail." VALUES 3>&1 1>&2 2>&3)
        checkCancel "You must enter an e-mail." && return
    done
    
    displayDialogBox --yesno "\nWould you like to set up a work account?"
    if [ $? -eq 1 ]; then
        nameSubst="s/PERSONAL_NAME/$gitPersonalName/g"
        mailSubst="s/PERSONAL_MAIL/$gitPersonalMail/g"
        sed -e "$nameSubst" -e "$mailSubst" templates/.gitconfig-notwork > ../dotfiles/.gitconfig
        return
    fi

    msg="\nEnter an absolute folder path where you would like to use the work account."
    gitWorkPath=$(displayDialogBox --inputbox "$msg" VALUES 3>&1 1>&2 2>&3)
    checkCancel "You must enter a path." && return
    gitWorkPath=$(echo "$gitWorkPath" | envsubst)
    mkdir -p "$gitWorkPath"
    while [[ ! -d "$gitWorkPath" ]]; do
        msg="\nPath isn't valid. Please try again."
        gitWorkPath=$(displayDialogBox --inputbox "$msg" VALUES 3>&1 1>&2 2>&3)
        checkCancel "You must enter a path." && return
        gitWorkPath=$(echo "$gitWorkPath" | envsubst)
        mkdir -p "$gitWorkPath"
    done
    gitWorkName=$(displayDialogBox --inputbox "\nEnter a name." VALUES 3>&1 1>&2 2>&3)
    checkCancel "You must enter a name." && return
    gitWorkMail=$(displayDialogBox --inputbox "\nEnter an e-mail." VALUES 3>&1 1>&2 2>&3)
    checkCancel "You must enter an e-mail." && return

    while true; do
        msg="\nPlease confirm that the data you entered is correct:\n\n -"
        msg="${msg} Name: ${gitWorkName}\n - E-mail: ${gitWorkMail}\n - Path: ${gitWorkPath}"
        displayDialogBox --yesno "$msg" && break
        gitWorkName=$(displayDialogBox --inputbox "\nEnter a name." VALUES 3>&1 1>&2 2>&3)
        checkCancel "You must enter a name." && return
        gitWorkMail=$(displayDialogBox --inputbox "\nEnter an e-mail." VALUES 3>&1 1>&2 2>&3)
        checkCancel "You must enter an e-mail." && return
    done

    nameSubst="s/PERSONAL_NAME/$gitPersonalName/g"
    mailSubst="s/PERSONAL_MAIL/$gitPersonalMail/g"
    pathSubst="s|WORK_PATH|$gitWorkPath|g"
    sed -e "$nameSubst" -e "$mailSubst" -e "$pathSubst" templates/.gitconfig > ../dotfiles/.gitconfig
    nameSubst="s/WORK_NAME/$gitWorkName/g"
    mailSubst="s/WORK_MAIL/$gitWorkMail/g"
    sed -e "$nameSubst" -e "$mailSubst" templates/.gitconfig-work > ../dotfiles/.gitconfig-work
}

checkForDependencies() {
    comm=$1 && [ "$1" = "libnewt" ] && comm=whiptail
    command -v "${comm}" &> /dev/null && return 0

    unameOutput=$(uname -a | grep -q "arch")
    if [ -f "/etc/arch-release" ] || [ "$unameOutput" -ne 1 ]; then
        sudo pacman --noconfirm --needed -Sy "${1}" && return 0
        echo "Couldn't install ${1}. We will continue without it."
    fi
    setDialogBox "plain"
    return 1
}

runUserScripts() {
    if [[ -n $userScriptsFlag && $userScriptsFlag = true ]]; then
        lastFolder=$(pwd -P)
        cd .. || { echo "Couldn't cd into parent folder." 1>&2 && exit 1; }

        local IFS=
        while read -r -d '' script; do
            source "$script"
        done < <(find -H scripts -type f -print0)

        cd "$lastFolder" || { echo "Couldn't cd into '$lastFolder'." 1>&2 && exit 1; }
    fi
}

startRice() {
    msg="\nThis script will configure gitconfig"
    if [[ -n $userScriptsFlag && $userScriptsFlag = true ]]; then
        msg="${msg}, install the dotfiles, and then run the scripts of the"
        msg="${msg} '$(basename "$PWD")/scripts' folder"
    else
        msg="${msg} and install the dotfiles"
    fi
    msg="${msg}. Would you like to continue?"
    displayDialogBox --title "sadedot" --yesno "$msg" || return
    displayDialogBox --infobox "\nUpdating sadedot submodule. Please wait." VALUES
    ( cd ..; sh sadedot/scripts/update.sh 2>&1 | debug )
    getGitconfigData
    source scripts/linkFiles.sh
    runUserScripts
    displayDialogBox --title "sadedot" --msgbox "\nAll done! Enjoy..."
}

runScript() {
    lastFolder=$(pwd -P)
    sadedotFolder=$(pwd -P | awk '{ sub(/sadedot.*/, "sadedot"); print }')
    cd "$sadedotFolder" || { echo "Couldn't cd into '$sadedotFolder'." 1>&2 && exit 1; }

    if [[ "$(basename "$sadedotFolder")" != "sadedot" ]]; then
        cd sadedot || { echo "Couldn't cd into 'sadedot'." 1>&2 && exit 1; }
    fi

    source scripts/common.sh
    checkParameters "$@"
    clear

    startRice

    clear
    cd "$lastFolder" || { echo "Couldn't cd into '$lastFolder'." 1>&2 && exit 1; }
}

runScript "$@"

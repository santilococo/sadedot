#!/usr/bin/env bash

usage() {
  cat << EOF
usage: ${0##*/} [command]
    -h                  Print this help message.
    -w                  Use whiptail.
    -d                  Use dialog.
EOF
}

checkParameters() {
    local counter=0
    while getopts ':hwd' flag; do
        if [ $((counter++)) -eq 1 ]; then
            usage
            exit 1
        fi

        case $flag in
            h)
                usage
                exit 0
                ;;
            w)
                checkForDependencies "libnewt"
                setDialogBox "whiptail"
                ;;
            d)
                checkForDependencies "dialog"
                setDialogBox "dialog"
                ;;
            ?)
                printf '%s: invalid option - '\''%s'\'\\n "${0##*/}" "$OPTARG"
                exit 1
                ;;
        esac
    done

    if [ $counter -eq 0 ]; then
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
    if [ "$1" = "libnewt" ]; then
        comm=whiptail
    else
        comm=$1
    fi

    command -v ${comm} &> /dev/null
    if [ $? -eq 1 ]; then
        unameOutput=$(uname -a | grep "arch")
        if [ -f "/etc/arch-release" ] || [ $unameOutput -eq 0 ]; then
            sudo pacman --noconfirm --needed -Sy ${1} > /dev/null 2>&1
            if [ $? -eq 1 ]; then
                echo "Couldn't install ${1}." >&2
                exit 1
            fi

            return
        fi

        echo "You must install ${1}." >&2
        exit 1
    fi
}

startRice() {
    displayDialogBox --title "CocoRice" --msgbox "Hi! This script will auto install my dotfiles."
    getGitconfigData
    sh scripts/linkFiles.sh
    sh scripts/install.sh
    displayDialogBox --title "CocoRice" --msgbox "All done! Enjoy..."
}

runScript() {
    lastFolder=$(pwd -P)
    cocoRiceFolder=$(pwd -P | awk '{ sub(/CocoRice.*/, "CocoRice"); print }')
    cd $cocoRiceFolder

    source scripts/common.sh
    checkParameters "$@"
    checkForDependencies

    startRice

    clear
    cd $lastFolder
}

runScript "$@"

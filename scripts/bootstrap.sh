#!/bin/sh

getGitconfigData() {
    dialog --stdout --yesno "Would you like to set up gitconfig?" 10 60
    if [ $? -eq 1 ]; then
        return
    fi

    dialog --msgbox "Now, I will ask you for data to set up gitconfig personal account." 10 60
    gitPersonalName=$(dialog --inputbox "Enter a name." 10 60 3>&1 1>&2 2>&3 3>&1)
    gitPersonalMail=$(dialog --inputbox "Enter a mail." 10 60 3>&1 1>&2 2>&3 3>&1)
    
    dialog --msgbox "Let's continue with the work account." 10 60
    gitWorkPath=$(dialog --inputbox "Enter a folder (absolute) path where you would like to use the work account." 10 60 3>&1 1>&2 2>&3 3>&1)
    while [[ ! -d $gitWorkPath ]]; do
        gitWorkPath=$(dialog --no-cancel --inputbox "Path isn't valid. Please try again" 10 60 3>&1 1>&2 2>&3 3>&1)
    done
    gitWorkName=$(dialog --inputbox "Enter a name." 10 60 3>&1 1>&2 2>&3 3>&1)
    gitWorkMail=$(dialog --inputbox "Enter a mail." 10 60 3>&1 1>&2 2>&3 3>&1)

    sed -e "s/PERSONAL_NAME/$gitPersonalName/g" -e "s/PERSONAL_MAIL/$gitPersonalMail/g" -e "s|WORK_PATH|${gitWorkPath}|g" ./templates/.gitconfig > ./dotfiles/.gitconfig
    sed -e "s/WORK_NAME/$gitWorkName/g" -e "s/WORK_MAIL/$gitWorkMail/g" ./templates/.gitconfig-work > ./dotfiles/.gitconfig-work
}

checkForDependencies() {
    commOuput=$(command -v dialog &> /dev/null)
    if [ $? -eq 1 ]; then
        unameOutput=$(uname -a | grep "arch")
        if [ -f "/etc/arch-release" ] || [ $unameOutput -eq 0 ]; then
            sudo pacman --noconfirm --needed -Sy dialog > /dev/null 2>&1
            if [ $? -eq 1 ]; then
                echo "You must have an active internet connection." >&2
                exit 1
            fi

            return
        fi

        echo "You must install dialog." >&2
        exit 1
    fi
}

startRice() {
    checkForDependencies

    lastFolder=$(pwd -P)
    cocoRiceFolder=$(echo "$(pwd -P)" | awk '{ sub(/CocoRice.*/, "CocoRice"); print }')
    cd $cocoRiceFolder

    dialog --title "CocoRice" --msgbox "Hi! This script will auto install my dotfiles. Make sure to backup your dotfiles!" 10 60
    getGitconfigData
    sh scripts/linkFiles.sh
    sh scripts/install.sh
    dialog --title "CocoRice" --msgbox "All done! Enjoy..." 10 60

    clear
    cd $lastFolder
}

startRice

#!/bin/sh

getGitconfigData() {
    whiptail --yesno "Would you like to set up gitconfig?" 0 0
    if [ $? -eq 1 ]; then
        return
    fi

    whiptail --msgbox "Now, I will ask you for data to set up gitconfig personal account." 10 60
    gitPersonalName=$(whiptail --inputbox "Enter a name." 0 0 3>&1 1>&2 2>&3)
    gitPersonalMail=$(whiptail --inputbox "Enter an e-mail." 0 0 3>&1 1>&2 2>&3)
    
    whiptail --msgbox "Let's continue with the work account." 0 0
    gitWorkPath=$(whiptail --inputbox "Enter an absolute folder path where you would like to use the work account." 0 0 3>&1 1>&2 2>&3)
    while [[ ! -d $gitWorkPath ]]; do
        gitWorkPath=$(whiptail --no-cancel --inputbox "Path isn't valid. Please try again" 0 0 3>&1 1>&2 2>&3)
    done
    gitWorkName=$(whiptail --inputbox "Enter a name." 0 0 3>&1 1>&2 2>&3)
    gitWorkMail=$(whiptail --inputbox "Enter an e-mail." 0 0 3>&1 1>&2 2>&3)

    sed -e "s/PERSONAL_NAME/$gitPersonalName/g" -e "s/PERSONAL_MAIL/$gitPersonalMail/g" -e "s|WORK_PATH|${gitWorkPath}|g" ./templates/.gitconfig > ./dotfiles/.gitconfig
    sed -e "s/WORK_NAME/$gitWorkName/g" -e "s/WORK_MAIL/$gitWorkMail/g" ./templates/.gitconfig-work > ./dotfiles/.gitconfig-work
}

checkForDependencies() {
    commOuput=$(command -v whiptail &> /dev/null)
    if [ $? -eq 1 ]; then
        unameOutput=$(uname -a | grep "arch")
        if [ -f "/etc/arch-release" ] || [ $unameOutput -eq 0 ]; then
            sudo pacman --noconfirm --needed -Sy libnewt > /dev/null 2>&1
            if [ $? -eq 1 ]; then
                echo "You must have an active internet connection." >&2
                exit 1
            fi

            return
        fi

        echo "You must install libnewt." >&2
        exit 1
    fi
}

startRice() {
    checkForDependencies

    lastFolder=$(pwd -P)
    cocoRiceFolder=$(echo "$(pwd -P)" | awk '{ sub(/CocoRice.*/, "CocoRice"); print }')
    cd $cocoRiceFolder

    whiptail --title "CocoRice" --msgbox "Hi! This script will auto install my dotfiles." 0 0
    getGitconfigData
    sh scripts/linkFiles.sh
    sh scripts/install.sh
    whiptail --title "CocoRice" --msgbox "All done! Enjoy..." 0 0

    clear
    cd $lastFolder
}

startRice

#!/bin/sh

getGitconfigData() {
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

startRice() {
    dialog --title "CocoRice" --msgbox "Hi! This script will auto install my dotfiles. Make sure to backup your dotfiles!" 10 60

    # getGitconfigData

    ./scripts/linkFiles.sh

    ./scripts/install.sh

    clear
}

startRice

#!/bin/sh

skip_all=false
overwrite_all=false
backup_all=false

linkFile() {
    if [[ -f "$2" ]]; then
        if [ "$skip_all" == "true" ]; then
            return
        elif [ "$overwrite_all" == "true" ]; then
            ln -sf "$1" "$2"
        elif [ "$backup_all" == "true" ]; then
            mv "$2" "${2}.backup"
            ln -s "$1" "$2"
        else
            selectedOption=$(dialog --menu "File already exists: $(basename "$1"), what would you like to do?" 10 60 0 1 "Skip" 2 "Skip all" 3 "Overwrite" 4 "Overwrite all" 5 "Backup" 6 "Backup all" 3>&1 1>&2 2>&3 3>&1)

            if [ $selectedOption -eq 1 ]; then
                return
            elif [ $selectedOption -eq 2 ]; then
                skip_all=true
                return
            elif [ $selectedOption -eq 3 ]; then
                ln -sf "$1" "$2"
            elif [ $selectedOption -eq 4 ]; then
                overwrite_all=true
                ln -sf "$1" "$2"
            elif [ $selectedOption -eq 5 ]; then
                mv "$2" "${2}.backup"
                ln -s "$1" "$2"
            else
                backup_all=true
                mv "$2" "${2}.backup"
                ln -s "$1" "$2"
            fi
        fi
    else
        ln -s "$1" "$2"
    fi
}

lastFolder=$(pwd -P)

DOTFILES=$(echo "$(pwd -P)" | awk '{ sub(/CocoRice.*/, "CocoRice"); print }')
cd $DOTFILES

DOTFILES_HOME=$DOTFILES/dotfiles
DOTFILES_CONFIG="$DOTFILES_HOME/.config"
DOTFILES_ICONS="$DOTFILES_HOME/.icons"
DOTFILES_SSH="$DOTFILES_HOME/.ssh"

for srcFile in $(find -H "$DOTFILES_HOME" -not -path '*.git' -not -path '*.config*' -not -path '*.ssh*' -not -path '*.icons*'); do
    if [ "$(basename "${srcFile}")" = "CocoRice" ] || [ "$(basename "${srcFile}")" = "dotfiles" ]; then
        continue
    fi

    if [[ -f "$srcFile" ]]; then
        linkFile "$srcFile" "$HOME/test/$(basename "${srcFile}")"
    fi
done

for initialFolder in "$DOTFILES_CONFIG" "$DOTFILES_ICONS" "$DOTFILES_SSH"; do
    for srcFile in $(find -H "$initialFolder"); do
        if [[ -d "$srcFile" ]]; then
            var=$(echo "$srcFile" | awk '{ sub(/.*CocoRice\/dotfiles\//, ""); print }')

            if [[ ! -d "$HOME/test/$var" ]]; then
                mkdir -p "$HOME/test/$var"
            fi
        fi

        if [[ -f "$srcFile" ]]; then
            var=$(echo "$srcFile" | awk '{ sub(/.*CocoRice\/dotfiles\//, ""); print }')
            linkFile "$srcFile" "$HOME/test/$var"
        fi
    done
done

cd $lastFolder
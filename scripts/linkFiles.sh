#!/usr/bin/env bash

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
            selectedOption=$(displayDialogBox --menu "File already exists: $(basename "$1"), what would you like to do?" VALUES 0 1 "Skip" 2 "Skip all" 3 "Overwrite" 4 "Overwrite all" 5 "Backup" 6 "Backup all" 3>&1 1>&2 2>&3)
            if [ $? -eq 1 ]; then
                exit 0
            fi

            if [ "$selectedOption" -eq 1 ]; then
                return
            elif [ "$selectedOption" -eq 2 ]; then
                skip_all=true
                return
            elif [ "$selectedOption" -eq 3 ]; then
                ln -sf "$1" "$2"
            elif [ "$selectedOption" -eq 4 ]; then
                overwrite_all=true
                ln -sf "$1" "$2"
            elif [ "$selectedOption" -eq 5 ]; then
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

loopThroughFiles() {
    COCORICE=$(pwd -P)
    DOTFILES="$COCORICE/dotfiles"
    DOTFILES_CONFIG="$DOTFILES/.config"
    DOTFILES_LOCAL="$DOTFILES/.local"
    DOTFILES_ICONS="$DOTFILES/.icons"
    DOTFILES_SSH="$DOTFILES/.ssh"

    local IFS=$'\n'
    for srcFile in $(find -H "$DOTFILES" -not -path '*.git' -not -path '*.config*' -not -path '*.ssh*' -not -path '*.icons*' -not -path '*.local*' -not -path '*other*'); do
        if [ "$(basename "${srcFile}")" = "CocoRice" ] || [ "$(basename "${srcFile}")" = "dotfiles" ]; then
            continue
        fi

        if [[ -f "$srcFile" ]]; then
            linkFile "$srcFile" "$HOME/$(basename "${srcFile}")"
        fi
    done

    for initialFolder in "$DOTFILES_CONFIG" "$DOTFILES_ICONS" "$DOTFILES_SSH" "$DOTFILES_LOCAL"; do
        for srcFile in $(find -H "$initialFolder"); do
            if [[ -d "$srcFile" ]]; then
                var=$(echo "$srcFile" | awk '{ sub(/.*CocoRice\/dotfiles\//, ""); print }')

                if [[ ! -d "$HOME/$var" ]]; then
                    mkdir -p "$HOME/$var"
                fi
            fi

            if [[ -f "$srcFile" ]]; then
                var=$(echo "$srcFile" | awk '{ sub(/.*CocoRice\/dotfiles\//, ""); print }')
                linkFile "$srcFile" "$HOME/$var"
            fi
        done
    done

    DOTFILES_OTHER=$DOTFILES/other

    if [ -d "$DOTFILES_OTHER" ]; then
        filesOutput=$(find -H "$DOTFILES_OTHER" | sed -n 2~1p | awk '{ sub(/.*CocoRice\/dotfiles\/other\//, ""); print }')
        files=""; for item in $filesOutput; do
            files="${files}$item\n"
        done
        displayDialogBox --yesno "There are 'other' files, would you like to install them?\n\n${files}" || return
    fi

    password=$(displayDialogBox --passwordbox "Enter your password" VALUES 3>&1 1>&2 2>&3)
    echo "$password" | sudo -S bash -c "" > /dev/null 2>&1
    echo "$password" | sudo -S bash -c "$(declare -f runDetachedScript); $(declare -f linkFile); runDetachedScript getDialogBox"
    unset password
}

runDetachedScript() {
    source scripts/common.sh
    setDialogBox "$1"

    DOTFILES_OTHER=$(pwd -P)/dotfiles/other

    local IFS=$'\n'
    for srcFile in $(find -H "$DOTFILES_OTHER"); do
        if [[ -d "$srcFile" ]]; then
            var=$(echo "$srcFile" | awk '{ sub(/.*CocoRice\/dotfiles\/other\//, ""); print }')

            if [[ ! -d "/$var" ]]; then
                mkdir -p "/$var"
            fi
        fi

        if [[ -f "$srcFile" ]]; then
            var=$(echo "$srcFile" | awk '{ sub(/.*CocoRice\/dotfiles\/other\//, ""); print }')
            linkFile "$srcFile" "/$var"
        fi
    done
}

runScript() {
    loopThroughFiles
}

runScript

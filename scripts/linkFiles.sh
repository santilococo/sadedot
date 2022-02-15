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
            msg="\nFile already exists: $(basename "$1"), what would you like to do?"
            options=(1 "Skip" 2 "Skip all" 3 "Overwrite" 4 "Overwrite all" 5 "Backup" 6 "Backup all")
            selectedOption=$(displayDialogBox --menu "$msg" VALUES 0 "${options[@]}" 3>&1 1>&2 2>&3)
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
        ln -sf "$1" "$2"
    fi
}

loopThroughFiles() {
    SADEDOT=$(pwd -P)
    DOTFILES="$SADEDOT/dotfiles"

    local IFS=
    while read -r -d '' srcFile; do
        if [ "$(basename "${srcFile}")" = "dotfiles" ]; then
            continue
        fi

        if [[ -f "$srcFile" ]]; then
            linkFile "$srcFile" "$HOME/$(basename "${srcFile}")"
        fi
    done < <(find -H "$DOTFILES" -maxdepth 1 -type f -print0)

    while read -r -d '' initialFolder; do
        while read -r -d '' srcFile; do
            if [[ -d "$srcFile" ]]; then
                var=$(echo "$srcFile" | awk '{ sub(/.*dotfiles\//, ""); print }')

                if [[ ! -d "$HOME/$var" ]]; then
                    mkdir -p "$HOME/$var"
                fi
            fi

            if [[ -f "$srcFile" ]]; then
                var=$(echo "$srcFile" | awk '{ sub(/.*dotfiles\//, ""); print }')
                linkFile "$srcFile" "$HOME/$var"
            fi
        done < <(find -H "$initialFolder" -print0)
    done < <(find -H "$DOTFILES" -maxdepth 1 -mindepth 1 -type d -not -path '*other*' -print0)

    if [ -d "$DOTFILES/other" ]; then
        msg="\nThere are 'other' files, would you like to install all of them"
        msg="${msg} or do you prefer to select which ones to install? Also, if"
        msg="${msg} you don't want to install them, you can press Cancel."
        buttons=("--yes-label" " Install all " "--extra-button")
        buttons+=("--extra-label" " Select which " "--no-label" " Cancel ")
        displayDialogBox "${buttons[@]}" --yesno "$msg"
        case $? in
            0) installAll=true ;;
            3) installAll=false ;;
            1) return ;;
        esac
        files=()
        while read -r -d '' srcFile; do
            file=$(echo "$srcFile" | awk '{ sub(/.*dotfiles\/other\//, ""); print }')
            msg="\nWould you like to install:\n\n'/$file'?"
            [ "$installAll" = true ] || displayDialogBox --yesno "$msg" || continue
            files+=("$srcFile")
        done < <(find -H "$DOTFILES/other" -mindepth 1 -type f -print0)
    fi

    password=$(displayDialogBox --passwordbox "\nEnter your password." VALUES 3>&1 1>&2 2>&3)
    echo "$password" | sudo -S bash -c "" > /dev/null 2>&1
    cmd="$(declare -f runDetachedScript); $(declare -f linkFile); runDetachedScript getDialogBox ${files[@]}"
    echo "$password" | sudo -S bash -c "$cmd"
    unset password
}

runDetachedScript() {
    source sadedot/scripts/common.sh
    setDialogBox "$1"

    SADEDOT=$(pwd -P)
    DOTFILES="$SADEDOT/dotfiles"

    local IFS=
    shift; for srcFile in "$@"; do
        var=$(echo "$srcFile" | awk '{ sub(/.*dotfiles\/other\//, ""); print }')
        
        varFolder=$(echo "$var" | sed "s/$(basename $var)//")
        if [[ ! -d "/$varFolder" ]]; then
            mkdir -p "/$var"
        fi

        linkFile "$srcFile" "/$var"
    done
}

runScript() {
    lastFolder=$(pwd -P)
    cd .. || { echo "Couldn't cd into parent folder." 1>&2 && exit 1; }

    loopThroughFiles

    cd "$lastFolder" || { echo "Couldn't cd into '$lastFolder'." 1>&2 && exit 1; }
}

runScript

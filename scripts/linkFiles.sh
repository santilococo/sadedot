#!/usr/bin/env bash

linkFile() {
    if [[ -f "$2" ]]; then
        if [ "$skipAll" == "true" ]; then
            return
        elif [ "$overwriteAll" == "true" ]; then
            ln -sf "$1" "$2"
        elif [ "$backupAll" == "true" ]; then
            mv "$2" "${2}.backup"
            ln -s "$1" "$2"
        else
            [ -h "$2" ] && [ "$1" = "$(realpath "$2")" ] && return

            msg="\nFile already exists: '${2//$HOME\//}', what would you like to do?"
            options=(1 "Skip" 2 "Skip all" 3 "Overwrite" 4 "Overwrite all" 5 "Backup" 6 "Backup all")
            selectedOption=$(displayDialogBox --menu "$msg" VALUES "${options[@]}" 3>&1 1>&2 2>&3)
            if [ $? -eq 1 ]; then
                exit 0
            fi

            if [ "$selectedOption" -eq 1 ]; then
                return
            elif [ "$selectedOption" -eq 2 ]; then
                skipAll=true
                return
            elif [ "$selectedOption" -eq 3 ]; then
                ln -sf "$1" "$2"
            elif [ "$selectedOption" -eq 4 ]; then
                overwriteAll=true
                ln -sf "$1" "$2"
            elif [ "$selectedOption" -eq 5 ]; then
                mv "$2" "${2}.backup"
                ln -s "$1" "$2"
            else
                backupAll=true
                mv "$2" "${2}.backup"
                ln -s "$1" "$2"
            fi
        fi
    else
        ln -sf "$1" "$2"
    fi
}

loopThroughFiles() {
    skipAll=false; overwriteAll=false; backupAll=false
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
        msg="${msg} or do you prefer to select which ones to install?"
        options=(1 "Install all" 2 "Select each")
        selectedOption=$(displayDialogBox --menu "$msg" VALUES "${options[@]}" 3>&1 1>&2 2>&3)
        [ $? -eq 1 ] && return
        case $selectedOption in
            1) installAll=true ;;
            2) installAll=false ;;
        esac
        files=()
        while read -r -d '' srcFile; do
            file=$(echo "$srcFile" | awk '{ sub(/.*dotfiles\/other\//, ""); print }')
            [ $installAll = true ] && files+=("$srcFile" " ") || files+=("$srcFile" "$file" "OFF")
        done < <(find -H "$DOTFILES/other" -mindepth 1 -type f -print0)

        if [ $installAll = false ]; then
            msg="\nSelect the files that you want to install."
            files=("$(displayDialogBox --checklist "$msg" VALUES "${files[@]}" 3>&1 1>&2 2>&3)")
            [ "${files[0]}" = '' ] && exit
            files=("${files[@]//$'\n'/ }")
        fi
    fi

    password=$(displayDialogBox --passwordbox "\nEnter your (sudo) password." VALUES 3>&1 1>&2 2>&3)
    echo "$password" | sudo -S bash -c "" > /dev/null 2>&1
    cmd="$(declare -f runDetachedScript); $(declare -f linkFile); runDetachedScript getDialogBox ${files[*]}"
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
        
        varFolder=${var//\/$(basename "$var")/}
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

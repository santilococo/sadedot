#!/bin/sh

lastFolder=$(pwd -P)

DOTFILES=$(echo "$(pwd -P)" | awk '{ sub(/CocoRice.*/, "CocoRice"); print }')
cd $DOTFILES

DOTFILES_HOME=$DOTFILES/dotfiles
DOTFILES_CONFIG="$DOTFILES_HOME/.config"
DOTFILES_ICONS="$DOTFILES_HOME/.icons"
DOTFILES_SSH="$DOTFILES_HOME/.ssh"

for srcFile in $(find -H "$DOTFILES_HOME" -not -path '*.git*' -not -path '*.config*' -not -path '*.ssh*' -not -path '*.icons*'); do
    if [ "$(basename "${srcFile}")" = "CocoRice" ] || [ "$(basename "${srcFile}")" = "dotfiles" ]; then
        continue
    fi

    ln -s "$srcFile" "$HOME/test/$(basename "${srcFile}")"
done

for initialFolder in "$DOTFILES_CONFIG" "$DOTFILES_ICONS" "$DOTFILES_SSH"; do
    for srcFile in $(find -H "$initialFolder"); do
        if [[ -d "$srcFile" ]]; then
            var=$(echo "$srcFile" | awk '{ sub(/.*CocoRice\/dotfiles\//, ""); print }')

            if [[ ! -d "$HOME/test/$var" ]]; then
                echo "$HOME/test/$var" "doesn't exists"
                mkdir -p "$HOME/test/$var"
            fi
        fi

        if [[ -f "$srcFile" ]]; then
            var=$(echo "$srcFile" | awk '{ sub(/.*CocoRice\/dotfiles\//, ""); print }')
            ln -s "$srcFile" "$HOME/test/$var"
        fi
    done
done

cd $lastFolder

# echo "$(dirname "$0")"
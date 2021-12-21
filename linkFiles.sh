#!/bin/sh

DOTFILES_HOME=$(pwd -P)
DOTFILES_CONFIG="$(pwd -P)/.config"
DOTFILES_ICONS="$(pwd -P)/.icons"
DOTFILES_SSH="$(pwd -P)/.ssh"

for src in $(find -H "$DOTFILES_HOME" -not -path '*.git*' -not -path '*.config*' -not -path '*.ssh*' -not -path '*.icons*'); do
    if [ "$(basename "${src}")" = "CocoRice" ]; then
		continue
    fi

    ln -s "$src" "$HOME/test/$(basename "${src}")"
done

for initialFolder in "$DOTFILES_CONFIG" "$DOTFILES_ICONS" "$DOTFILES_SSH"; do
	for src in $(find -H "$initialFolder"); do
		if [[ -d "$src" ]]; then
			var=$(echo "$src" | awk '{ sub(/.*CocoRice\//, ""); print }')

			if [[ ! -d "$HOME/test/$var" ]]; then
				echo "$HOME/test/$var" "doesn't exists"
				mkdir -p "$HOME/test/$var"
			fi
		fi

		if [[ -f "$src" ]]; then
			var=$(echo "$src" | awk '{ sub(/.*CocoRice\//, ""); print }')
			ln -s "$src" "$HOME/test/$var"
		fi
	done
done
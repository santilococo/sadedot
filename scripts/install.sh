#!/usr/bin/env bash

cloneAndMake() {
    if [ -z $password ]; then
        password=$(displayDialogBox --passwordbox "Enter your password" VALUES 3>&1 1>&2 2>&3)
        echo "$password" | sudo -S bash -c "" > /dev/null 2>&1
    fi
    displayDialogBox --infobox "Downloading ${1}" VALUES
    git clone "$2" 2>&1 | debug
    (cd "$1" || { echo "Couldn't cd into '$1'." 1>&2 && exit 1; }; echo "$password" | sudo make install 2>&1 | debug)
}

downloadAndInstallPackages() {
    DOTFILES_CONFIG="$HOME/.config"
    cd "$DOTFILES_CONFIG" || { echo "Couldn't cd into '$DOTFILES_CONFIG'." 1>&2 && exit 1; }

    if [[ ! -d "dwmblocks" ]]; then
        cloneAndMake "dwmblocks" "https://github.com/santilococo/dwmblocks.git"
    fi
    if [[ ! -d "dwm" ]]; then
        cloneAndMake "dwm" "https://github.com/santilococo/dwm.git"
    fi
    if [[ ! -d "st" ]]; then
        cloneAndMake "st" "https://github.com/santilococo/st.git"
    fi
    if [[ ! -d "dmenu" ]]; then
        cloneAndMake "dmenu" "https://github.com/santilococo/dmenu.git"
    fi
    if [[ ! -d "clipmenu" ]]; then
        cloneAndMake "clipmenu" "https://github.com/cdown/clipmenu.git"
    fi
}

runScript() {
    downloadAndInstallPackages
}

runScript

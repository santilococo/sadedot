#!/usr/bin/env bash

cloneAndMake() {
    displayDialogBox --infobox "Downloading ${1}" VALUES
    git clone $2 > /dev/null 2>&1
    (cd $1; sudo make install > /dev/null 2>&1)
}

downloadAndInstallPackages() {
    DOTFILES_CONFIG=$HOME/.config
    cd $DOTFILES_CONFIG

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
        cloneAndMake "clipmenu" "https://github.com/santilococo/clipmenu.git"
    fi
}

runScript() {
    source scripts/common.sh
    downloadAndInstallPackages
}

runScript

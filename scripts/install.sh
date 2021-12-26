#!/bin/sh

cloneAndMake() {
    # git clone --progress $2 2>&1 | dialog --progressbox "Downloading ${1}" 0 0
    whiptail "Downloading ${1}" 0 0
    git clone $2 2>&1
    cd $1; sudo make install; cd ..
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
}

downloadAndInstallPackages
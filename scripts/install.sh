#!/bin/sh

makeInstall() {
    cd $1
    sudo make install
    cd ..
}

downloadAndInstallPackages() {
    DOTFILES_CONFIG=$HOME/test/.config

    cd $DOTFILES_CONFIG

    if [[ ! -d "dwmblocks" ]]; then
        git clone --progress https://github.com/santilococo/dwmblocks.git 2>&1 | dialog --progressbox "Downloading dwmblocks" 10 60
        makeInstall "dwmblocks"
    fi
    if [[ ! -d "dwm" ]]; then
        git clone --progress https://github.com/santilococo/dwm.git 2>&1 | dialog --progressbox "Downloading dwm" 10 60
        makeInstall "dwm"
    fi
    if [[ ! -d "st" ]]; then
        git clone --progress https://github.com/santilococo/st.git 2>&1 | dialog --progressbox "Downloading st" 10 60
        makeInstall "st"
    fi
    if [[ ! -d "dmenu" ]]; then
        git clone --progress https://github.com/santilococo/dmenu.git 2>&1 | dialog --progressbox "Downloading dmenu" 10 60
        makeInstall "dmenu"
    fi
}

downloadAndInstallPackages
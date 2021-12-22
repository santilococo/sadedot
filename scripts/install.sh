#!/bin/sh

DOTFILES_CONFIG=$HOME/test/.config

cd $DOTFILES_CONFIG

downloaded=false

if [[ ! -d "dwmblocks" ]]; then
    git clone --progress https://github.com/santilococo/dwmblocks.git 2>&1 | dialog --progressbox "Downloading dwmblocks" 10 60
    downloaded=true
fi
if [[ ! -d "dwm" ]]; then
    git clone --progress https://github.com/santilococo/dwm.git 2>&1 | dialog --progressbox "Downloading dwm" 10 60
    downloaded=true
fi
if [[ ! -d "st" ]]; then
    git clone --progress https://github.com/santilococo/st.git 2>&1 | dialog --progressbox "Downloading st" 10 60
    downloaded=true
fi
if [[ ! -d "dmenu" ]]; then
    git clone --progress https://github.com/santilococo/dmenu.git 2>&1 | dialog --progressbox "Downloading dmenu" 10 60
    downloaded=true
fi

if [ downloaded = true ]; then
    sudo echo -n
fi

#cd dwmblocks && sudo make install
#cd dwm && sudo make install
#cd st && sudo make install
#cd dmenu && sudo make install

#!/bin/sh

DOTFILES_CONFIG=$HOME/test/.config

cd $DOTFILES_CONFIG

downloaded=false

if [[ ! -d "dwmblocks" ]]; then
    git clone https://github.com/santilococo/dwmblocks.git
    downloaded=true
fi
if [[ ! -d "dwm" ]]; then
    git clone https://github.com/santilococo/dwm.git
    downloaded=true
fi
if [[ ! -d "st" ]]; then
    git clone https://github.com/santilococo/st.git
    downloaded=true
fi
if [[ ! -d "dmenu" ]]; then
    git clone https://github.com/santilococo/dmenu.git
    downloaded=true
fi

if [ downloaded = true ]; then
    sudo echo -n
fi

#cd dwmblocks && sudo make install
#cd dwm && sudo make install
#cd st && sudo make install
#cd dmenu && sudo make install

#!/bin/sh

DOTFILES_CONFIG=$HOME/test/.config

cd $DOTFILES_CONFIG

git clone https://github.com/santilococo/dwmblocks.git
git clone https://github.com/santilococo/dwm.git
git clone https://github.com/santilococo/st.git
git clone https://github.com/santilococo/dmenu.git

sudo echo -n

#cd dwmblocks && sudo make install
#cd dwm && sudo make install
#cd st && sudo make install
#cd dmenu && sudo make install

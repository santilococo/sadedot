# Runs only once https://unix.stackexchange.com/questions/71253/what-should-shouldnt-go-in-zshenv-zshrc-zlogin-zprofile-zlogout

source ~/.zshrc_exports

if ! echo $PATH | grep -q "$HOME/.local/bin"; then
    export PATH=$PATH:$HOME/.local/bin
fi

export PATH=$PATH:$HOME/.local/share/gem/ruby/3.0.0/bin

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then 
    exec startx
    #ssh-agent startx
fi

#!/usr/bin/env bash

updateSubmodules() {
    git submodule update --remote --merge
    gitStatus=$(git status --porcelain)
    grep -q "sadedot" <(echo "$gitStatus") || return
    git commit -m "Update sadedot submodule" sadedot
    git push
}

runScript() {
    lastFolder=$PWD
    sadedotParentFolder=$(pwd -P | awk '{ sub(/\/sadedot.*/, ""); print }')
    cd "$sadedotParentFolder" || { echo "Couldn't cd into '$sadedotParentFolder'." 1>&2 && exit 1; }

    updateSubmodules

    cd "$lastFolder" || { echo "Couldn't cd into '$lastFolder'." 1>&2 && exit 1; }
}

runScript
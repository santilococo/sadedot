#!/usr/bin/env bash

runScript() {
    git submodule update --remote --merge
    gitStatus=$(git status --porcelain)
    grep -q "sadedot" <(echo "$gitStatus") || return
    git commit -m "Update sadedot submodule" sadedot
    git push
}

runScript
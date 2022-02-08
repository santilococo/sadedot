#!/usr/bin/env bash

git submodule update --remote --merge
gitStatus=$(git status --porcelain)
grep -q "sadedot" <(echo "$gitStatus") || return
git commit -m "Update sadedot submodule" sadedot
git push

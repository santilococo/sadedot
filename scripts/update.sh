#!/usr/bin/env bash

git submodule foreach git pull
git commit -m "Update sadedot submodule" sadedot
git push

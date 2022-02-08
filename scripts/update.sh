#!/usr/bin/env bash

git submodule update --remote --merge
git commit -m "Update sadedot submodule" sadedot
git push

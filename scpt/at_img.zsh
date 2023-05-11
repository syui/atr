#!/bin/zsh

dir=${0:a:h}
f=$HOME/.config/atr/scpt/png/t.jpg

atr img-upload $f|jq -r .blob.ref.'"$link"'

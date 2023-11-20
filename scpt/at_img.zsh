#!/bin/zsh

dir=${0:a:h}
f=$HOME/.config/atr/scpt/png/t.png

link=`atr img-upload $f|jq -r .blob.ref.'"$link"'`
cid=$1
uri=$2
atr img-post "#stablediffusion" -l $link -c $cid -u $uri

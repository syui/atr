#!/bin/zsh

dir=${0:a:h}
f=$HOME/.config/atr/scpt/png/t.png
f_sleep=$HOME/.config/atr/scpt/png/sleep

cid=$1
uri=$2
if [ ! -f $f ];then
	atr r "limit 1 day" -c $cid -u $uri
	exit
fi
if [ -f $f_sleep ];then
	link=bafkreidgp2cl4cvkn3i4gzqj6kfiwngjjh5ie2jwobh632jh4ejlbiwdhm
	atr img-post "#nyancat" -l $link -c $cid -u $uri
	rm $f_sleep
	exit
fi	

link=`atr img-upload $f|jq -r .blob.ref.'"$link"'`
atr img-post "#stablediffusion" -l $link -c $cid -u $uri

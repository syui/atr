#!/bin/zsh

echo "not open"
exit

atr=$HOME/.cargo/bin/atr 
url_j=https://card.syui.ai/json/card.json
tcid=$HOME/.config/atr/txt/tmp_notify_cid.txt

handle=$1
did=$2
cid=$3
uri=$4

if [ ! -d $HOME/.config/atr/txt ];then
	mkdir -p $HOME/.config/atr/txt
fi

case $OSTYPE in
	darwin*)
		alias date="/opt/homebrew/bin/gdate"
		;;
esac

url=https://api.syui.ai
username=`echo $1|cut -d . -f 1`
link=https://card.syui.ai/$username
ran=$(($RANDOM % 10))

if [ $ran -eq 1 ];then
	uranai="今日の運勢をルーン占いでやってください。結果を120文字以内で教えてください"
else
	uranai="今日の運勢をタロット占いでやってください。結果を120文字以内で教えてください"
fi

body=`$atr chat "$uranai" -c`
if $atr r "$body" -c $cid -u $uri;then
	echo $cid >! $tcid
fi
exit

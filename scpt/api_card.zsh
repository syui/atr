#!/bin/zsh

case $OSTYPE in
	darwin*)
		alias date="/opt/homebrew/bin/gdate"
		;;
esac
d=`date +"%Y%m%d"`
nd=`date +"%Y%m%d" -d '1 day'`
username=`echo $1|cut -d . -f 1`
url=https://api.syui.ai
f=$HOME/.config/atr/scpt/t.webp

if [ -z "$1" ];then
	exit
fi

data=`curl -sL $url/users|jq ".[]|select(.username == \"$username\")"`
if [ -z "$data" ];then
	data=`curl -X POST -H "Content-Type: application/json" -d "{\"username\":\"$username\"}" -s $url/users`
	echo $data|jq -r .username
fi
next=`echo $data|jq -r .next`
if [ $next -gt $d ];then
	echo limit 1 day
	echo "next : $nd"
	t=0
	curl -sL -o $f https://card.syui.ai/card/card_${t}.webp
	exit
fi

uid=`echo $data|jq -r ".id"`
tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid}" -s $url/cards`
card=`echo $tmp|jq -r .card`
card_url=`echo $tmp|jq -r .url`
cp=`echo $tmp|jq -r .cp`
echo card : $card
echo cp : $cp
t=`echo $tmp|jq -r .card`
tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"next\":\"$nd\"}" -s $url/users/$uid`
next=`echo $tmp|jq -r .next`
echo next : $next
echo url : $card_url

f=$HOME/.config/atr/scpt/t.webp
curl -sL -o $f https://card.syui.ai/card/card_${t}.webp

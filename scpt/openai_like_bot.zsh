#!/bin/zsh

atr=$HOME/.cargo/bin/atr 
url=https://api.syui.ai

if [ "$2" = "reset" ];then
	echo reset : $1
	username=`echo $1|cut -d . -f 1`
	uid=`curl -sL "$url/users?itemsPerPage=3000"|jq ".[]|select(.username == \"$username\")"|jq -r .id`
	like=0
	token=`cat $HOME/.config/atr/api_card.json|jq -r .token`
	tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"like\":\"$like\", \"token\":\"$token\"}" -s $url/users/$uid`
	exit
fi

s=$((RANDOM % 5))
json=`curl -sL "https://api.syui.ai/users?itemsPerPage=3000"|jq "sort_by(.like)|reverse|.[$s]"`

case $OSTYPE in
	darwin*)
		alias date="/opt/homebrew/bin/gdate"
		;;
esac

username=`echo $json|jq -r .username`
did=`echo $json|jq -r .did`
link=https://card.syui.ai/$username
uid=`echo $json|jq -r .id`

data=`curl -sL "$url/users/$uid"`
like_old=`echo $data|jq -r .like`

echo $data

#test
if [ "$1" = "-t" ];then
	echo $json
	did=did:plc:uqzpqmrjnptsxezjx4xuh2mn
	like_old=6
fi

if [ $like_old -ge 100 ];then
	text=`$atr chat "相手に好きな気持を伝えてください" -c|sed '/^$/d'`
	$atr @ $did -p "$text"
	exit
fi

if [ $like_old -ge 15 ];then
	text=`$atr chat "相手を心配してください" -c|sed '/^$/d'`
	$atr @ $did -p "$text"
	exit
fi

if [ $like_old -ge 5 ];then
	text=`$atr chat "自己紹介してください" -c|sed '/^$/d'`
	$atr @ $did -p "$text"
	exit
fi

exit

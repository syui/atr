#!/bin/zsh

case $OSTYPE in
	darwin*)
		alias date="/opt/homebrew/bin/gdate"
		;;
esac

atr=$HOME/.cargo/bin/atr 
host_card=https://card.syui.ai/json/card.json
pass=`cat $HOME/.config/atr/api_card.json|jq -r .password`
token=`cat $HOME/.config/atr/api_card.json|jq -r .token`
eat_file=$HOME/.config/atr/txt/nyancat_eat.txt
eat=`cat $eat_file|awk "NR==1"`

if [ -z "$eat" ];then 
	exit
fi

body_d="thx!
A＿＿A
|・ㅅ・ |
|っ　ｃ|
`cat $eat_file|awk "NR==1"`
 U￣￣U"

host=https://api.syui.ai
data=`curl -sL "$host/users?itemsPerPage=3000"|jq ".[]|select(.like >= 10)"`
tmp=`echo $data|jq -s`
n=`echo $tmp|jq "length"`
ran=$(($RANDOM % n - 1))
echo $ran
user=`echo $tmp|jq -r ".[$ran].username"`
did=`echo $tmp|jq -r ".[$ran].did"`
echo $atr @ $did -p "`echo $body_d`"
$atr @ $did -p "`echo $body_d`"

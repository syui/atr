#!/bin/zsh

case $OSTYPE in
	darwin*)
		alias date="/opt/homebrew/bin/gdate"
		;;
esac

atr=$HOME/.cargo/bin/atr 
host=https://api.syui.ai
host_card=https://card.syui.ai/json/card.json
pass=`cat $HOME/.config/atr/api_card.json|jq -r .password`
token=`cat $HOME/.config/atr/api_card.json|jq -r .token`
handle=$1
username=`echo $1|cut -d . -f 1`
did=$2
cid=$3
uri=$4
pay=10000

all_data=`curl -sL "$host/users?itemsPerPage=3000"`
data=`echo $all_data|jq ".[]|select(.username == \"$username\")"`
uid=`echo $data|jq -r .id`
aiten=`echo $data|jq -r .aiten`

pay_s=$((aiten - pay))
if [ $pay_s -lt 0 ] || [ -z "$pay_s" ];then
	echo "aiten : $aiten >= $pay"
	exit
fi

ai_aiten_old=`curl -sL $host/users/2|jq -r .aiten`
ai_aiten=$((ai_aiten_old + pay))

echo "10000 : $username ---> ai"
echo "---"
echo "$username : $pay_s"
echo "ai : $ai_aiten"

tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"token\":\"$token\", \"aiten\": $pay_s}" -s $host/users/$uid`
tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"token\":\"$token\", \"aiten\": $ai_aiten}" -s $host/users/2`

#!/bin/zsh

handle=$1
did=$2
text=$3

atr=$HOME/.cargo/bin/atr 
url_j=https://card.syui.ai/json/card.json
handle=$1
did=$2
cid=$3
uri=$4

case $OSTYPE in
	darwin*)
		alias date="/opt/homebrew/bin/gdate"
		;;
esac

url=https://api.syui.ai
username=`echo $1|cut -d . -f 1`
link=https://card.syui.ai/$username
uid=`curl -sL "$url/users?itemsPerPage=2000"|jq ".[]|select(.username == \"$username\")"|jq -r .id`
echo $uid

data=`curl -sL "$url/users/$uid"`
like_old=`echo $data|jq -r .like`

nolike=$(($RANDOM % 30))
like=$(($RANDOM % 10))
like_at=`date --iso-8601=seconds`
token=`cat $HOME/.config/atr/api_card.json|jq -r .token`

echo nolike $nolike
echo like $like

#if [ $like_old -eq 100 ];then
#	$atr follow $did
#	like=$((1 + like_old))
#	curl -X PATCH -H "Content-Type: application/json" -d "{\"token\":\"$token\", \"like\": $like}" -s $url/users/$uid
#fi

if { [ $like -eq 1 ] && echo $text|grep -e "ありがとう" -e "うれしい" } || [ $nolike -eq 1 ];then
	echo ok
	$atr @ $handle -p "♡"
	like=$((1 + like_old))
	curl -X PATCH -H "Content-Type: application/json" -d "{\"token\":\"$token\", \"like\": $like}" -s $url/users/$uid
fi
exit

#!/bin/zsh

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

if [ -z $uid ] || [ "$uid" = "null" ];then
	$atr r "api error" -c $cid -u $uri
	exit
fi

data=`curl -sL "$url/users/$uid"`
data_u=`curl -sL "$url/users/$uid/card?itemsPerPage=2000"`
luck_at=`echo $data|jq -r .luck_at`
luck_at_n=`date --iso-8601=seconds`
luck_at=`date -d "$luck_at" +"%Y%m%d"`
day_at=`date +"%Y%m%d"`
nd=`date +"%Y%m%d" -d '1 days ago'`

if [ "$luck_at" = "$day_at" ];then
	$atr r "limit day" -c $cid -u $uri
	exit
fi

cp_i=`echo $data_u |jq -r "sort_by(.cp) | reverse|.[].card"|sort|uniq|sed -e '1d'`
cp_n=`echo $cp_i|wc -l`

if [ 3 -gt $cp_n ];then
	$atr r "card rare 3-type required" -c $cid -u $uri
	exit
fi

ran=$(($RANDOM % $cp_n + 1))
luck=$(($RANDOM % 8))
sub=$(($RANDOM % 15))
card=`echo $cp_i|awk "NR==$ran"`

if [ $sub -eq $card ];then
	sub="x2"
else
	sub=`curl -sL $url_j|jq -r ".[]|select(.id == $sub)|.p"`
fi
j=`curl -sL $url_j|jq ".[]|select(.id == $card)"`
img=`echo $j|jq -r .img`

if [ -z $img ] || [ "$img" = "null" ];then
	exit
fi

title=`echo $j|jq -r .h`
title="今日の運勢"
desc=`echo $j|jq -r .p`

if [ 0 -eq $luck ];then
	desc="危険"
fi

if [ 1 -eq $luck ];then
	desc="要注意"
fi

if [ 2 -eq $luck ];then
	desc="注意"
fi

if [ 3 -eq $luck ];then
	desc="普通"
fi

if [ 4 -eq $luck ];then
	desc="順調"
fi
if [ 5 -eq $luck ];then
	desc="好調"
fi

if [ 6 -eq $luck ];then
	desc="絶好調"
fi

if [ 7 -eq $luck ];then
	desc="超越"
fi

body=`echo "luck : $luck/7"`
echo $body
tmp=`$atr reply-og "$body" --cid $cid --uri $uri --img $img --title "$title" --description "$desc" --link $link`
pass=`cat $HOME/.config/atr/api_card.json|jq -r .password`
token=`cat $HOME/.config/atr/api_card.json|jq -r .token`

if [ $luck -eq 7 ];then
	tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"luck_at\":\"$luck_at_n\",\"token\":\"$token\",\"luck\": $luck, \"next\": \"$nd\"}" -s $url/users/$uid`
else
	tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"luck_at\":\"$luck_at_n\",\"token\":\"$token\",\"luck\": $luck}" -s $url/users/$uid`
fi
exit

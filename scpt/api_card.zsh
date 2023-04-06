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
url_user_all="$url/users?itemsPerPage=255"
f=$HOME/.config/atr/scpt/t.webp
pass=`cat $HOME/.config/atr/api_card.json|jq -r .password`
if [ -z "$1" ];then
	exit
fi

data=`curl -sL $url_user_all|jq ".[]|select(.username == \"$username\")"`
if [ -z "$data" ];then
	data=`curl -X POST -H "Content-Type: application/json" -d "{\"username\":\"$username\",\"password\":\"$pass\"}" -s $url/users`
	echo $data|jq -r .username
fi
next=`echo $data|jq -r .next`
uid=`echo $data|jq -r ".id"`

# battle
updated_at=`echo $data|jq -r .updated_at`
updated_at_n=`date --iso-8601=seconds`
updated_at=`date -d "$updated_at" +"%Y%m%d"`

if [ "$2" = "-b" ];then
	if [ $updated_at -ge $d ];then
		echo "limit battle"
	else
		len=`curl -sL $url_user_all|jq length`
		r=$(($RANDOM % $len))
		if [ 0 -eq $r ];then
			r=1
		fi

		data_u=`curl -sL $url/users/$uid/card`
		#echo $data_u|jq ".[].cp"
		nl=`echo $data_u|jq length`
		if [ $nl -ge 3 ];then
			rs=$(($RANDOM % 3 + 1))
		else
			rs=$(($RANDOM % $nl + 1))
		fi
		tt=`echo $data_u|jq ".[].cp"|sort -n -r`
		echo $tt | sed -n 1,3p
		echo "---"
		cp_i=`echo $tt |awk "NR==$rs"`

		data_u=`curl -sL $url/users/$r/card`
		#echo $data_u|jq ".[].cp"
		nl=`echo $data_u|jq length`
		rs=$(($RANDOM % $nl))
		if [ $nl -ge 3 ];then
			rs=$(($RANDOM % 3 + 1))
		else
			rs=$(($RANDOM % $nl + 1))
		fi
		tt=`echo $data_u|jq ".[].cp"|sort -n -r`
		echo id : $r
		echo $tt | sed -n 1,3p
		cp_b=`echo $tt |awk "NR==$rs"`
		echo "---"
		echo $cp_i vs $cp_b

		if [ $cp_i -gt $cp_b ];then
			echo "win!"
		else
			echo loss
		fi

		if [ $cp_i -gt $cp_b ];then
			tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"password\":\"$pass\"}" -s $url/cards`
			card=`echo $tmp|jq -r .card`
			card_url=`echo $tmp|jq -r .url`
			cp=`echo $tmp|jq -r .cp`
			echo card : $card
			echo cp : $cp
			t=`echo $tmp|jq -r .card`
		fi

		tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"updated_at\":\"$updated_at_n\"}" -s $url/users/$uid`

	fi
	exit
fi

if [ $next -gt $d ];then
	echo limit 1 day
	echo "next : $nd"
	t=0
	#curl -sL -o $f https://card.syui.ai/card/card_${t}.webp
	exit
fi

tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"password\":\"$pass\"}" -s $url/cards`
card=`echo $tmp|jq -r .card`
card_url=`echo $tmp|jq -r .url`
cp=`echo $tmp|jq -r .cp`
echo card : $card
echo cp : $cp
t=`echo $tmp|jq -r .card`
tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"next\":\"$nd\"}" -s $url/users/$uid`
next=`echo $tmp|jq -r .next`
echo next : $next

#f=$HOME/.config/atr/scpt/t.webp
#curl -sL -o $f https://card.syui.ai/card/card_${t}.webp

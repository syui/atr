#!/bin/zsh

case $OSTYPE in
	darwin*)
		alias date="/opt/homebrew/bin/gdate"
		;;
esac

atr=$HOME/.cargo/bin/atr
host=https://api.syui.ai

pass=`cat $HOME/.config/atr/api_card.json|jq -r .password`
token=`cat $HOME/.config/atr/api_card.json|jq -r .token`

egg_card=40

handle=$1
did=$2
username=`echo $1|cut -d . -f 1`
opt=$3

if [ -z "$opt" ];then
	echo no option
	exit
fi

all_data=`curl -sL "$host/users?itemsPerPage=3000"`
data=`echo $all_data|jq ".[]|select(.username == \"$username\")"`
uid=`echo $data|jq -r .id`

aiten=`echo $data|jq -r .aiten`
fav=`echo $data|jq -r .fav`
day_at=`date +"%Y%m%d"`
nd=`date +"%Y%m%d" -d '1 days ago'`
ten_at_n=`date --iso-8601=seconds`
d=`date +"%Y%m%d"`
limit_reset_at=`date --iso-8601=seconds -d '1 days ago'`
data_user_card=`curl -sL "$host/users/$uid/card?itemsPerPage=3000"`

opt_dec=`echo $opt|base64 -d`

if [ "$did" = "$opt_dec" ];then
	echo verify
else
	echo no verify
	exit
fi

fav_card=`echo $data_user_card|jq -r ".[]|select(.card == $egg_card)"`
cid=`echo $fav_card|jq -r .id`

egg_at=`echo $data|jq -r .egg_at`
egg_at=`date -d "$egg_at" +"%Y%m%d"`
egg_at_n=`date --iso-8601=seconds`

day_m=`date +"%H%M"`
day_mm=`date +"%H%M" -d "-1 min"`
day_mmm=`date +"%H%M" -d "-2 min"`

if [ -z "$fav_card" ];then
	echo "no egg"
	if [ "$egg_at" = "$d" ];then
		echo "limit egg"
		exit
	fi
	card=39
	data_uu=`curl -sL "$host/users/$uid/card?itemsPerPage=2000"`
	card_check=`echo $data_uu|jq -r ".[]|select(.card == $card)|.cp"|head -n 1`
	if [ -n "$card_check" ];then
		cp=$card_check
		cid=`echo $data_uu|jq -r ".[]|select(.card == $card)|.id"|head -n 1`
		echo "you already have, dragon"
		ran=`echo $(($RANDOM % 3))`
		ran_a=`echo $(($RANDOM % 5 + 1))`
		if [ $ran -eq 1 ];then
			card_check=$((card_check * 3))
			echo "🐉 ---> $cp +${ran_a}"
			cp=$((cp + ran_a))
		else
			cp=$((cp + 1))
			echo "$cp +1"
		fi
		tmp=`curl -sL -X PATCH -H "Content-Type: application/json" -d "{\"cp\":$cp,\"token\":\"$token\"}" $host/cards/$cid`
		tmp=`curl -sL -X PATCH -H "Content-Type: application/json" -d "{\"egg_at\":\"$egg_at_n\", \"token\":\"$token\"}" -s $host/users/$uid`
		exit
	fi

	card=42
	cp=0
	data_uu=`curl -sL "$host/users/$uid/card?itemsPerPage=2000"`
	card_check=`echo $data_uu|jq -r ".[]|select(.card == $card)|.cp"|head -n 1`
	if [ -n "$card_check" ];then
		echo "you already have, nyan"
		ran=`echo $(($RANDOM % 1000 + 1000))`
		aiten_p=$((aiten + ran))
		echo "🐈 ---> [aiten]${aiten} +${ran}"
		tmp=`curl -sL -X PATCH -H "Content-Type: application/json" -d "{\"egg_at\":\"$egg_at_n\", \"aiten\":$aiten_p, \"token\":\"$token\"}" -s $host/users/$uid`
		exit
	fi

	exit
fi

card_id=`echo $fav_card|jq -r ".id"`
card_cp=`echo $fav_card|jq -r ".cp"`
card_name=`echo $fav_card|jq -r ".card"`
card_status=`echo $fav_card|jq -r ".status"`
card_skill=`echo $fav_card|jq -r ".skill"`

function fav_status() {
	echo "\n[card] ${card_name}"
	echo "---"
	echo "cp : ${card_cp}"
	echo "cid : ${cid}"
	echo "skill : ${card_skill}"
	echo "status : ${card_status}"
}

function fav_battle() {
	cp_b=`echo $(($RANDOM % 14))`
	if [ "$egg_at" = "$d" ];then
		echo "limit egg"
		exit
	fi

	cp_i=`echo $fav_card|jq -r ".cp"`
	card_name=`echo $fav_card|jq -r ".card"`
	card_status=`echo $fav_card|jq -r ".status"`
	card_skill=`echo $fav_card|jq -r ".skill"`

	if [ $cp_i -ge $cp_b ];then
		card=39
		skill=dragon
		cp=`echo $(($RANDOM % 1000 + 1200))`
		s=third
		ran=`echo $(($RANDOM % 10))`
		if [ $ran -eq 1 ];then
			card=42
			skill=nyan
			cp=0
		fi
		body="...congratulations! your egg has evolved\negg ---> ${skill} !!"
		tmp=`curl -sL -X PATCH -H "Content-Type: application/json" -d "{\"card\": $card,\"cp\":$cp,\"token\":\"$token\", \"status\": \"$s\",\"skill\": \"$skill\"}" $host/cards/$cid`
	else
		body="...no evolved"
	fi
	echo "\n${cp_i} vs $cp_b"
	echo "----"
	echo "${body}"
	tmp=`curl -sL -X PATCH -H "Content-Type: application/json" -d "{\"egg_at\":\"$egg_at_n\",\"token\":\"$token\"}" -s $host/users/$uid`
	exit
}

fav_battle

exit

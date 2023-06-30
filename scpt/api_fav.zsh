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

handle=$1
did=$2
username=`echo $1|cut -d . -f 1`
opt=$3

if [ -z "$opt" ];then
	echo no option
	echo "---"
	echo "CID = 1234567"
	echo "@yui.syui.ai /fav 1234567"
	echo "---"
	echo "/fav status"
	echo "/fav battle"
	exit
fi

all_data=`curl -sL "$host/users?itemsPerPage=3000"`
data=`echo $all_data|jq ".[]|select(.username == \"$username\")"`
uid=`echo $data|jq -r .id`

if [ $opt -eq 0 ];then
	tmp=`curl -sL -X PATCH -H "Content-Type: application/json" -d "{\"fav\": $opt,\"token\":\"$token\"}" -s $host/users/$uid`
	echo ok
	exit
fi

aiten=`echo $data|jq -r .aiten`
fav=`echo $data|jq -r .fav`
day_at=`date +"%Y%m%d"`
nd=`date +"%Y%m%d" -d '1 days ago'`
ten_at_n=`date --iso-8601=seconds`
d=`date +"%Y%m%d"`
limit_reset_at=`date --iso-8601=seconds -d '1 days ago'`
data_user_card=`curl -sL "$host/users/$uid/card?itemsPerPage=3000"`

case "$opt" in
	[bB]|-[bB]|[bB]attle|[sS]|-[sS]|[sS]tatus)
		cid=`echo $data|jq -r .fav`
		fav_card=`echo $data_user_card|jq -r ".[]|select(.id == $cid)"`
		;;
	*)
		opt=$((opt + 0))
		cid=$opt
		fav_card=`echo $data_user_card|jq -r ".[]|select(.id == $cid)"`
		;;
esac

updated_at=`echo $data|jq -r .updated_at`
updated_at_m=`date -d "$updated_at" +"%H%M"`
updated_at_n=`date --iso-8601=seconds`
updated_at=`date -d "$updated_at" +"%Y%m%d"`
raid_at=`echo $data|jq -r .raid_at`
raid_at=`date -d "$raid_at" +"%Y%m%d"`
raid_at_n=`date --iso-8601=seconds`
day_m=`date +"%H%M"`
day_mm=`date +"%H%M" -d "-1 min"`
day_mmm=`date +"%H%M" -d "-2 min"`

if [ -z "$fav_card" ];then
	echo "no card id"
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
	if [ $updated_at -ge $d ] || [ "$updated_at" = "$d" ];then
		echo "limit battle"
		exit
	fi

	cp_i=`echo $fav_card|jq -r ".cp"`
	card_name=`echo $fav_card|jq -r ".card"`
	card_status=`echo $fav_card|jq -r ".status"`
	card_skill=`echo $fav_card|jq -r ".skill"`
	cp_b=$(($RANDOM % 1400))

	if [ $cp_i -gt $cp_b ];then
		cp_plus=$(($RANDOM % 30))
	else
		cp_plus=$(($RANDOM % 5))
	fi
	echo "\n✧${cp_i} vs $cp_b"
	echo "----"
	cp=$((cp_i + cp_plus))
	body="level up!"
	echo "${body} ✧${cp}(+${cp_plus})"
	tmp=`curl -sL -X PATCH -H "Content-Type: application/json" -d "{\"cp\":$cp,\"token\":\"$token\"}" $host/cards/$cid`
	tmp=`curl -sL -X PATCH -H "Content-Type: application/json" -d "{\"updated_at\":\"$updated_at_n\",\"token\":\"$token\"}" -s $host/users/$uid`
	exit
}

function fav_add() {
	card_status=second
	u_data=`curl -sL "https://api.syui.ai/users/$uid/card?itemsPerPage=2555"|jq -r ".[]|select(.status == \"second\")"`
	if [ -z "$u_data" ];then
		d_data=`curl -sL $host/cards/$cid|jq -r "select(.status == \"first\")"`
		if [ -z "$d_data" ];then
			echo status $card_status
			tmp=`curl -sL -X PATCH -H "Content-Type: application/json" -d "{\"status\":\"$card_status\",\"token\":\"$token\"}" $host/cards/$cid`
		fi
	fi

	tmp=`curl -sL -X PATCH -H "Content-Type: application/json" -d "{\"fav\": $opt,\"token\":\"$token\"}" -s $host/users/$uid`
	if [ -n "$tmp" ];then
		echo ok
	fi
	exit
}

case "$opt" in
	[bB]|-[bB]|[bB]attle)
		fav_battle
		;;
	[sS]|-[sS]|[sS]tatus)
		fav_status
		;;
		*)
		fav_add
		;;
esac

exit

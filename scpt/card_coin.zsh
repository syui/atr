#!/bin/zsh

case $OSTYPE in
	darwin*)
		alias date="/opt/homebrew/bin/gdate"
		;;
esac

coin_now=`curl -sL https://blockchain.info/ticker|jq -r .JPY.last|cut -d . -f 1`
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

function card_s(){
	
	all_data=`curl -sL "$host/users?itemsPerPage=3000"`
	data=`echo $all_data|jq ".[]|select(.username == \"$username\")"`
	uid=`echo $data|jq -r .id`
	aiten=`echo $data|jq -r .aiten`
	coin=`echo $data|jq -r .coin`
	coin_open=`echo $data|jq -r .coin_open`
	date_check=`date +"%Y-%m-%d"`
	coin_at=`echo $data|jq -r .coin_at`
	coin_at=`date -d "$coin_at" +"%Y-%m-%d"`
	coin_at_n=`date --iso-8601=seconds`
	limit_reset_at=`date --iso-8601=seconds -d '1 days ago'`

	if [ "$coin_open" = "false" ];then
		echo -e "[start]\ncoin(start) : $coin_now\naiten : +0"
		echo "---"
		echo "check : /ten bit"
		echo "exit : /ten coin"
		tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"token\":\"$token\", \"coin\":$coin_now, \"coin_open\": true}" -s $host/users/$uid`
		exit
	fi

	coin_plus=$((coin_now - coin))
	if [ $coin_plus -ge 1 ];then
		aiten_plus=$((aiten * 1.1 + coin_plus))
		aiten_san=$((aiten_plus - aiten))
	elif [ $coin_plus -ge 1000 ];then 
		aiten_plus=$((aiten * 1.2 + coin_plus))
		aiten_san=$((aiten_plus - aiten))
	elif [ $coin_plus -ge 10000 ];then 
		aiten_plus=$((aiten * 1.5 + coin_plus))
		aiten_san=$((aiten_plus - aiten))
	elif [ $coin_plus -ge 50000 ];then 
		aiten_plus=$((aiten * 3 + coin_plus))
		aiten_san=$((aiten_plus - aiten))
	elif [ $coin_plus -ge 100000 ];then 
		aiten_plus=$((aiten * 10 + coin_plus))
		aiten_san=$((aiten_plus - aiten))
	elif [ $coin_plus -ge -1000 ];then
		aiten_plus=$((aiten - coin_now))
		aiten_san=$((aiten_plus - aiten))
	elif [ $coin_plus -ge -10000 ] && [ $aiten -ge 100000 ];then
		aiten_plus=$((aiten / 1.05 - coin_plus))
		aiten_san=$((aiten_plus - aiten))
	elif [ $coin_plus -ge -10000 ];then
		aiten_plus=$((aiten / 1.05))
		aiten_san=$((aiten_plus - aiten))
	elif [ $coin_plus -ge -100000 ];then
		aiten_plus=$((aiten / 1.1))
		aiten_san=$((aiten_plus - aiten))
	elif [ $coin_plus -ge -1000000 ];then
		aiten_plus=$((aiten / 1.2))
		aiten_san=$((aiten_plus - aiten))
	elif [ $coin_plus -le -1000000 ];then
		aiten_plus=$((aiten / 1.3))
		aiten_san=$((aiten_plus - aiten))
	else
		aiten_plus=$aiten
		aiten_san=0
	fi
	aiten_plus=`echo $aiten_plus|cut -d . -f 1`
	aiten_san=`echo $aiten_san|cut -d . -f 1`

}

function card_d() {
	j=`curl -sL $host_card |jq -r ".[]|select(.coin_skill == true)"|jq -s`
	n=`echo $j|jq length`
	n_leng=$n
	n=$(($RANDOM % n - 1))
	card=`echo $j|jq -r ".[$n].id"`
	img=`echo $j|jq -r ".[$n].img"`
	ten=`echo $j|jq -r ".[$n].ten"`
	title=`echo $j|jq -r ".[$n].h"`
	title="[$title]"
	ran_a=$(($RANDOM % 1000))
	cp=$((ran_a + 500))
	ran_s=$(($RANDOM % 5))
	skill=ten
	if [ $ran_s -eq 1 ];then
		s=super
		cp=$((cp + $ran_a))
	else
		s=normal
	fi

	data_uu=`curl -sL "$host/users/$uid/card?itemsPerPage=2000"`
	card_check=`echo $data_uu|jq -r ".[]|select(.card == $card)"`
	card_check_skill=`echo $card_check|jq "select(.skill == \"$skill\")"`

	if [ -z "$card_check" ] && [ -z "$card_check_skill" ] && [ $coin_plus -ge 1000 ] && [ "$coin_open" = "true" ] && [ "$date_check" != "$coin_at" ];then
		text="[card]\nid : $card\ncp : $cp"
		tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$card,\"status\":\"$s\",\"cp\":$cp,\"password\":\"$pass\",\"skill\":\"$skill\"}" -s $host/cards`
		echo "$text"
	fi

}

function card_p() {
	if [ $aiten_san -ge 0 ];then
		aiten_san="+${aiten_san}"
	fi

	if [ "$date_check" = "$coin_at" ];then
		echo "coin(now) : $coin_now\ncoin(start) : $coin\naiten : $aiten_san ..."
		echo "---"
		echo "exit limit, next day!"
		exit
	fi

	if [ "$coin_open" = "true" ];then
		tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"token\":\"$token\", \"aiten\": $aiten_plus, \"coin\":0, \"coin_open\": false, \"coin_at\" : \"$coin_at_n\"}" -s $host/users/$uid`
		echo -e "[exit]\ncoin(start) : $coin\ncoin(now) : $coin_now\naiten : $aiten_san ---> $aiten_plus"
	fi
}

card_s
card_d
card_p

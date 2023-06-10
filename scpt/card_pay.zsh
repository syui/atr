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

echo $handle

function card_d(){
	j=`curl -sL $host_card |jq -r ".[]|select(.ten_skill == true)"|jq -s`
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
	body_d=`echo "[card]\nid : $card\ncp : $cp\nstatus : $s\nskill : $skill"`
}

function card_user(){
	all_data=`curl -sL "$host/users?itemsPerPage=3000"`
	data=`echo $all_data|jq ".[]|select(.username == \"$username\")"`
	uid=`echo $data|jq -r .id`
	aiten=`echo $data|jq -r .aiten`
	ten_data=`echo $all_data|jq ".|sort_by(.aiten)|reverse|.[]|select(.aiten >= $pay)"`
	if [ -z "$ten_data" ] || [ -z "$aiten" ] || [ $aiten -le $pay ];then
		echo "aiten : $aiten >= $pay [1/${n_leng}]"
		exit
	else
		pay_s=$((aiten - pay))
		if [ $pay_s -lt 0 ] || [ -z "$pay_s" ];then
			echo "aiten : $aiten >= $pay [1/${n_leng}]"
			exit
		fi
		body_user=`echo "${aiten} : $aiten - $pay = $pay_s [1/${n_leng}]"`
	fi
}

function card_check(){
	data_uu=`curl -sL "$host/users/$uid/card?itemsPerPage=2000"`
	card_check=`echo $data_uu|jq -r ".[]|select(.card == $card)"`
	if [ -n "$card_check" ];then
		echo "$body_user"
		echo "lost, you already have..."
		tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"token\":\"$token\", \"aiten\": $pay_s}" -s $host/users/$uid`
		exit
	fi
}

function card_pay(){
	link=https://card.syui.ai/$username
	text=`echo "$body_user\n$body_d"`
	desc="[$ten]"
	tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"token\":\"$token\", \"aiten\": $pay_s}" -s $host/users/$uid`
	tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$card,\"status\":\"$s\",\"cp\":$cp,\"password\":\"$pass\",\"skill\":\"$skill\"}" -s $host/cards`
	echo "$text"
	#echo "$atr reply-og \"$text\" --cid $cid --uri $uri --img $img --title \"$title\" --description \"$desc\" --link $link"
	#tmp_atr=`$atr reply-og "$text" --cid $cid --uri $uri --img $img --title "$title" --description "$desc" --link $link`
}

card_d
card_user
card_check
card_pay

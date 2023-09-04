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
pay=40000

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
	#card=1;skill=3d;s=3d
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
	card_check_skill=`echo $card_check|jq "select(.skill == \"$skill\")"`
	if [ -n "$card_check" ] && [ -n "$card_check_skill" ];then
		card=0
		cp=1
		s=super
		skill=lost
		if [ `echo $((RANDOM % 6))` -eq 0 ];then
			card=`echo $((RANDOM % 14))`
			cp=0
			s=3d
			skill=3d
		fi
		echo "$body_user"
		echo "lost, you chose the card you already have..."
		echo "try again next time!"
		echo "[card]"
		echo "id : $card"
		echo "cp : $cp"
		echo "skill : $skill"
		tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"token\":\"$token\", \"aiten\": $pay_s}" -s $host/users/$uid`
		tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$card,\"status\":\"$s\",\"cp\":$cp,\"password\":\"$pass\",\"skill\":\"$skill\"}" -s $host/cards`
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

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
pay=60000

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
	
	all_data=`curl -sL "$host/users?itemsPerPage=3000"`
	data=`echo $all_data|jq ".[]|select(.username == \"$username\")"`
	uid=`echo $data|jq -r .id`
	aiten=`echo $data|jq -r .aiten`
	model=`echo $data|jq -r .model`
	model_mode=`echo $data|jq -r .model_mode`
	model_attack=`echo $data|jq -r .model_attack`
	model_skill=`echo $data|jq -r .model_skill`
	model_limit=`echo $data|jq -r .model_limit`
	model_critical=`echo $data|jq -r .model_critical`
	model_critical_d=`echo $data|jq -r .model_critical_d`
	ten_data=`echo $all_data|jq ".|sort_by(.aiten)|reverse|.[]|select(.aiten >= $pay)"`

	model_critical=$((RANDOM % 10 + model_critical))
	json_model="{\"model_critical\":$model_critical, \"token\":\"$token\"}"
	body_d=`echo "[card]\nid : $card\ncp : $cp\nstatus : $s\nskill : $skill\n---\n[model]\ncritical : ${model_critical}%"`
}

function card_user(){
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

		echo "$body_user"
		echo "lost, you chose the card you already have..."
		echo "ai[model] Lv up!"

		s_up=$((RANDOM % 3 + 1))
		case `echo $((RANDOM % 4))` in
			0)
				model_mode=$((model_mode + s_up))
				json="{\"token\":\"$token\", \"model_mode\": $model_mode}"
				echo "\"mode\": Lv${model_mode}"
				;;
			1)
				model_attack=$((model_attack + s_up))
				json="{\"token\":\"$token\", \"model_attack\": $model_attack}"
				echo "\"attack\": Lv${model_attack}"
				;;
			2)
				model_skill=$((model_skill + s_up))
				json="{\"token\":\"$token\", \"model_skill\": $model_skill}"
				echo "\"skill\": Lv${model_skill}"
				;;
			3)
				model_limit=$((model_limit + s_up))
				json="{\"token\":\"$token\", \"model_limit\": $model_limit}"
				echo "\"burst\": Lv${model_limit}"
				;;
			*)
				model_limit=$((model_limit + s_up))
				json="{\"token\":\"$token\", \"model_limit\": $model_limit}"
				echo "\"burst\": Lv${model_limit}"
				;;
		esac
		tmp=`curl -X PATCH -H "Content-Type: application/json" -d "$json" -s $host/users/$uid`

		card=0
		cp=1
		s=super
		skill=lost
		#echo "try again next time!"

		echo "[card]"
		echo "id : $card"
		echo "cp : $cp"
		echo "skill : $skill"
		if [ "$handle" != "ai" ];then
			tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"token\":\"$token\", \"aiten\": $pay_s}" -s $host/users/$uid`
		fi
		tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$card,\"status\":\"$s\",\"cp\":$cp,\"password\":\"$pass\",\"skill\":\"$skill\"}" -s $host/cards`
		exit
	fi
}

function card_pay(){
	link=https://card.syui.ai/$username
	text=`echo "$body_user\n$body_d"`
	desc="[$ten]"
	if [ "$handle" != "ai" ];then
		tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"token\":\"$token\", \"aiten\": $pay_s, \"model_critical\": $model_critical}" -s $host/users/$uid`
	else
		tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"token\":\"$token\", \"aiten\": 10000000, \"model_critical\": $model_critical}" -s $host/users/$uid`
		echo $tmp
	fi
	tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$card,\"status\":\"$s\",\"cp\":$cp,\"password\":\"$pass\",\"skill\":\"$skill\"}" -s $host/cards`
	echo "$text"
	#echo "$atr reply-og \"$text\" --cid $cid --uri $uri --img $img --title \"$title\" --description \"$desc\" --link $link"
	#tmp_atr=`$atr reply-og "$text" --cid $cid --uri $uri --img $img --title "$title" --description "$desc" --link $link`
}

card_d
card_user
card_check
card_pay

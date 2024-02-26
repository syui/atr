#!/bin/zsh

case $OSTYPE in
	darwin*)
		alias date="/opt/homebrew/bin/gdate"
		;;
esac

help_body="[AITEN]
/ten start : ゲームスタート
/ten pay : aitenを貯めてカードをゲット
文字カードの組み合わせで点数を上げていきます
1ターンにつき1枚またはすべてのカードをten dで入れ替えられます。7ターンで終了
数字を指定すると、たまにmissをします
カードの組み合わせはten pで発動します
[AA] : [通] 50
[KKK] : [揃] 100
[AAM] : [天ノ川] 1200"

if [ -z "$5" ];then
	echo "$help_body"
	exit
fi

card_pay=$HOME/.config/atr/scpt/card_pay.zsh
card_coin=$HOME/.config/atr/scpt/card_coin.zsh
card_aicoin=$HOME/.config/atr/scpt/card_aicoin.zsh
atr=$HOME/.cargo/bin/atr
host=https://api.syui.ai
host_card=https://card.syui.ai/json/card.json
host_card_json=`curl -sL $host_card`
n_cid=$HOME/.config/atr/txt/tmp_notify_cid.txt
f_cfg=$HOME/.config/atr/txt/tmp_ten_config.txt

function moon_check(){
	moon_now=`date +"%Y%m%d"`
	moon_j=$HOME/.config/atr/scpt/full_moon.j
	if [ -f $moon_j ];then
		moon_t=`cat $moon_j|jq ".[]|select(.data == \"$moon_now\")"`
		if [ -n "$moon_t" ];then
			echo true
		else
			echo false
		fi
	fi
}

if [ ! -f $f_cfg ];then
	echo $host_card_json |jq -r ".[]|select(.ten != null)|.ten" |tr -d '\n' >! $f_cfg
fi

if [ -f $f_cfg ];then
	nn=`cat $f_cfg|wc -c`
fi

ran_a=$(($RANDOM % nn))
ran_b=$(($RANDOM % nn))
ran_c=$(($RANDOM % nn))
ran_d=$(($RANDOM % nn))
ran_z=$(($RANDOM % 540))
ran_cm=$(($RANDOM % 3))
ran_first=$(($RANDOM % 6))

pass=`cat $HOME/.config/atr/api_card.json|jq -r .password`
token=`cat $HOME/.config/atr/api_card.json|jq -r .token`

handle=$1
did=$2
username=`echo $1|cut -d . -f 1`
cid=$3
uri=$4
option=$5
sub_option=$6
cid_b=$7
uri_b=$8
ten_kai=0

if [ "$sub_option" = "coin" ];then
	option=coin_com
	sub_option=$5
fi

export LC_CTYPE=C
export LC_ALL=C

function ten_yaku() {
	echo $host_card_json |jq -r ".[]|select(.ten != null)|.ten,.h"
}

function ten_skill() {
	skill_card_id=`echo $host_card_json |jq -r ".[]|select(.ten == \"$1\")|.id"`
	data_user_card=`curl -sL "$host/users/$uid/card?itemsPerPage=3000"`
	skill_card=`echo $data_user_card|jq -r ".[]|select(.skill == \"ten\")|select(.card == $skill_card_id)"`
	if [ -n "$skill_card" ];then
		echo true
	else
		echo false
	fi
}

function ten_skill_yui() {
	skill_card_id=`echo $host_card_json |jq -r ".[]|select(.ten == \"$1\")|.id"`
	data_user_card=`curl -sL "$host/users/$uid/card?itemsPerPage=3000"`
	skill_card=`echo $data_user_card|jq -r ".[]|select(.skill == \"yui\")|select(.card == $skill_card_id)"`
	if [ -n "$skill_card" ];then
		echo true
	else
		echo false
	fi
}

function card_son_check() {
	data_user_card=`curl -sL "$host/users/$uid/card?itemsPerPage=3000"`
	card_yui_check=`echo $data_user_card|jq -r ".[]|select(.card == $1)"`
	if [ -n "$card_yui_check" ];then
		echo true
	else
		echo false
	fi
}

function card_ar_check() {
	data_user_card=`curl -sL "$host/users/$uid/card?itemsPerPage=3000"`
	card_yui_check=`echo $data_user_card|jq -r ".[]|select(.card == $1)|select(.status == \"3d\")"`
	if [ -n "$card_yui_check" ];then
		echo true
	else
		echo false
	fi
}

function card_yui_check() {
	data_user_card=`curl -sL "$host/users/$uid/card?itemsPerPage=3000"`
	card_yui_check=`echo $data_user_card|jq -r ".[]|select(.card == 47)"`
	if [ -n "$card_yui_check" ];then
		echo true
	else
		echo false
	fi
}

function card_kyoku_check() {
	data_user_card=`curl -sL "$host/users/$uid/card?itemsPerPage=3000"`
	card_kyoku_check=`echo $data_user_card|jq -r ".[]|select(.card == 90)"`
	if [ -n "$card_kyoku_check" ];then
		card_kyoku_o_check=`echo $data_user_card|jq -r ".[]|select(.card == 15)"`
		if [ -n "$card_kyoku_o_check" ];then
			echo origin
		else
			echo true
		fi
	else
		echo false
	fi
}

function card_kyoku_o_check() {
	data_user_card=`curl -sL "$host/users/$uid/card?itemsPerPage=3000"`
	if [ -n "$card_kyoku_o_check" ];then
		echo true
	else
		echo false
	fi
}

function card_chou_check() {
	data_user_card=`curl -sL "$host/users/$uid/card?itemsPerPage=3000"`
	card_yui_check=`echo $data_user_card|jq -r ".[]|select(.card == 14)"|jq -s length`
	if [ -n "$card_yui_check" ];then
		echo $card_yui_check
	else
		echo 0
	fi
}

function ten_yak_check() {
	unset ten_yak_ok
	case "$1" in
		OUY|AIK|IIK|AIS|ACH|ACC|IOU|EKS|TUY|AAC|AEK|ETU|ETW|IKU|IIT)
			if `ten_skill $1`;then
				export ten_yak_ok="☑"
			fi
			;;
		YUI|ACH|IOU|EKS)
			if `ten_skill_yui $1`;then
				export ten_yak_ok="☑"
			fi
			;;
		EMY|KOS|CHI|AIT|OYZ|IKY|AKM|KUY|AW*|AHK|IKT|AAM|OSZ|CHO|AAA|AA*|AI*)
			export ten_yak_ok="⚠"
			;;
	esac
}

function ten_char() {
	unset miss
	old_ten_char=$ten_char
	char_a=`cat $f_cfg| cut -c $ran_a`
	char_b=`cat $f_cfg| cut -c $ran_b`
	char_c=`cat $f_cfg| cut -c $ran_c`
	ten_char=`echo "${char_a}\n${char_b}\n${char_c}"|head -n 3|sort|tr -d '\n'`

	if [ "${ten_char}" = "AHO" ];then
		ten_char=CHO
	fi
	if [ ${#ten_char} -eq 0 ];then
		#miss="[miss]"
		ten_char=AAA
	fi
	if [ ${#ten_char} -eq 1 ];then
		#miss="[miss]"
		ten_char=AA${ten_char}
	fi
	if [ ${#ten_char} -eq 2 ];then
		#miss="[miss]"
		ten_char=A${ten_char}
	fi

	ten_yak_check $ten_char
	if [ -z "$ten_yak_ok" ];then
		if [ $ran_first -eq 1 ];then
			ten_char=EMY
		fi
	fi
	ten_yak_check $ten_char
	if [ -z "$ten_yak_ok" ];then
		if [ $ran_first -eq 2 ];then
			ten_char=AAA
		fi
	fi
}

function ten_char_one() {
	ten_char_one=`cat $f_cfg| cut -c $ran_d`
}

function ten_room_id() {
	ten_room_id=`cat /dev/urandom | tr -dc 'a-z' | fold -w 5|head -n 1`
}

function ten_data_reset() {
	ten_data=`curl -sL "$host/users?itemsPerPage=3000"|jq ".|sort_by(.ten_su)|reverse|.[]|select(.ten_su != 0)"`
	ten_u_tmp=`echo $ten_data|jq -s`
	ten_n_tmp=`echo $ten_u_tmp|jq "length"`
	#ten_n_tmp=5
	for ((i=0;i<$ten_n_tmp;i++))
	do
		u_i=`echo $ten_u_tmp|jq -r ".[$i].id"`
		u_a=`echo $ten_u_tmp|jq -r ".[$i].username"`
		u_s=`echo $ten_u_tmp|jq -r ".[$i].ten_su"`
		echo "---"
		echo "user : $u_a"
		echo "ten : $u_s"
	done
}

function ten_user_reset() {
	if [ "$handle" = "syui.ai" ];then
		limit_reset_at=`date --iso-8601=seconds -d '1 days ago'`
		ten_data_reset_tmp=`curl -sL "$host/users?itemsPerPage=3000"|jq ".[]|select(.aiten != 0)"`
		ten_u_tmp=`echo $ten_data_reset_tmp|jq -s`
		ten_n_tmp=`echo $ten_u_tmp|jq "length"`
		for ((i=0;i<$ten_n_tmp;i++))
		do
			u_a=`echo $ten_u_tmp|jq -r ".[$i].username"`
			u_s=`echo $ten_u_tmp|jq -r ".[$i].ten_su"`
			u_i=`echo $ten_u_tmp|jq -r ".[$i].id"`
			ten_kai=0
			tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"ten\": false,\"token\":\"$token\", \"ten_at\": \"$limit_reset_at\"}" -s $host/users/$u_i`
		done
		echo reset
	else
		echo no admin
	fi
}

if { [ "$handle" = "syui.ai" ] && [ "$option" = "reset" ] } || [ "$handle" = "reset" ] || [ "$handle" = "r" ];then
	ten_char
	ten_kai=1
	tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"ten_post\": \"\", \"ten_kai\":0,\"ten_su\":0,\"ten\": false,\"token\":\"$token\"}" -s $host/users/1`
fi

function ten_user_stop() {
	echo stop
	echo user : $handle
	echo ten :	$ten_su
	echo aiten :	$((aiten + ten_su))
	tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"ten_post\": \"0\", \"ten_kai\":0,\"ten_su\":$ten_su,\"ten\": false,\"token\":\"$token\", \"ten_at\": \"$ten_at_n\",\"aiten\": $((aiten + ten_su))}" -s $host/users/$uid`
	exit
}

function ten_start() {
	if "$ten_bool" ;then
		echo already started
		exit
	fi
	ten_yak_check $ten_post
	if [ -n "$ten_yak_ok" ];then
		ten_old_yak=$ten_post
	fi

	if [ ${#ten_char} -eq 0 ];then
		ten_char=AAA
	fi
	if [ ${#ten_char} -eq 1 ];then
		ten_char=AA${ten_char}
	fi
	if [ ${#ten_char} -eq 2 ];then
		ten_char=A${ten_char}
	fi
	ten_yak_check $ten_char

	if [ -z "$ten_yak_ok" ];then
		if [ "`card_kyoku_check`" = "true" ];then
			card=89
			ten_char=ETW
			export ten_yak_ok="☑"
		elif [ "`card_kyoku_check`" = "origin" ];then
			card=89
			ten_char=ETW
			export ten_yak_ok='⚠'
		else
			unset card
		fi
	fi

	if [ -z "$ten_yak_ok" ] && [ $ran_first -eq 1 ];then
		ten_char=EMY
	fi

	if [ -n "$ten_old_yak" ];then
		ten_char=$ten_old_yak
	fi

	ten_yak_check $ten_char

	if [ -z "$ten_yak_ok" ];then
		if `ten_skill IIK`;then
			card=46
			ten_char=IIK
			export ten_yak_ok="☑"
		else
			unset card
		fi
	fi

	if [ -z "$ten_yak_ok" ];then
		if `ten_skill YUI`;then
			card=36
			ten_char=YUI
			export ten_yak_ok="☑"
		else
			unset card
		fi
	fi

	if [ -z "$ten_yak_ok" ];then
		if `ten_skill AIK`;then
			card=33
			ten_char=AIK
			export ten_yak_ok="☑"
		else
			unset card
		fi
	fi

	if [ -z "$ten_yak_ok" ];then
		if `ten_skill OUY`;then
			card=29
			ten_char=OUY
			export ten_yak_ok="☑"
		else
			unset card
		fi
	fi

	if [ -z "$ten_yak_ok" ];then
		if `ten_skill ACC`;then
			card=76
			ten_char=ACC
			export ten_yak_ok="☑"
		else
			unset card
		fi
	fi

	ten_user=`echo $ten_data|jq -r .username`
	find_user=`echo $ten_user|grep $username`
	first_ten=1000
	echo "join : $handle [${ten_char}]"
	echo "ten : $first_ten"
	echo "aiten : $aiten"
	echo "---"
	echo "[1-7]"
	echo "ten d : shuffle[${ten_char}${ten_yak_ok}]"
	echo "ten p : post"
	echo "---"
	tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"ten_post\": \"$ten_char\", \"ten_kai\":0,\"ten_su\":$first_ten,\"ten\": true,\"token\":\"$token\"}" -s $host/users/$uid`
	text_one=`echo $ten_data|jq -r .username,.ten_su`
	#echo $text_one
	exit
}

function ten_other_user() {
	ten_data=`curl -sL "$host/users?itemsPerPage=3000"|jq ".[]|select(.ten == true)"`
	ten_user=`echo $ten_data|jq -r .username`
	other_user=`echo $ten_user|grep -v $username`
}

function user_env() {
	all_data=`curl -sL "$host/users?itemsPerPage=3000"`
	ten_data=`echo $all_data|jq ".|sort_by(.ten_su)|reverse|.[]|select(.ten_su != 0)"`
	data=`echo $all_data|jq ".[]|select(.username == \"$username\")"`
	uid=`echo $data|jq -r .id`
	aiten=`echo $data|jq -r .aiten`
	coin=`echo $data|jq -r .coin`
	coin_open=`echo $data|jq -r .coin_open`
	model=`echo $data|jq -r .model`
	# card=2
	model_mode=`echo $data|jq -r .model_mode`
	# card=8
	model_attack=`echo $data|jq -r .model_attack`
	# card=3
	model_skill=`echo $data|jq -r .model_skill`
	# card=7
	model_limit=`echo $data|jq -r .model_limit`
	model_critical=`echo $data|jq -r .model_critical`
	model_critical_d=`echo $data|jq -r .model_critical_d`
	ten_post=`echo $data|jq -r .ten_post`
	ten_bool=`echo $data|jq -r .ten`
	day_at=`date +"%Y%m%d"`
	nd=`date +"%Y%m%d" -d '1 days ago'`
	ten_at_n=`date --iso-8601=seconds`
	limit_reset_at=`date --iso-8601=seconds -d '1 days ago'`
	d=`date +"%Y-%m-%d"`
	ten_at=`echo $data|jq -r .ten_at`
	ten_at=`date -d "$ten_at" +"%Y-%m-%d"`
	if [ "$d" = "$ten_at" ] && [ "$handle" != "ai" ];then
		echo "limit aiten"
		exit
	fi
	ten_kai=`echo $data|jq -r .ten_kai`
}

function coin_env() {
	all_data=`curl -sL "$host/users?itemsPerPage=3000"`
	ten_data=`echo $all_data|jq ".|sort_by(.ten_su)|reverse|.[]|select(.ten_su != 0)"`
	data=`echo $all_data|jq ".[]|select(.username == \"$username\")"`
	uid=`echo $data|jq -r .id`
	aiten=`echo $data|jq -r .aiten`
	coin=`echo $data|jq -r .coin`
	coin_open=`echo $data|jq -r .coin_open`

	coin_now=`curl -sL https://blockchain.info/ticker|jq -r .JPY.last|cut -d . -f 1`
	coin_plus=$((coin_now - coin))

	echo "[check]"
	echo "coin(now) : $coin_now"

	if [ "$coin_open" = "false" ];then
		echo "---"
		echo "start : /ten coin"
		exit
	fi

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
		aiten_plus=$((aiten - coin_plus))
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

	if [ $aiten_san -ge 0 ];then
		aiten_san="+${aiten_san}"
	fi

	if [ "$coin_open" = "true" ];then
		echo "coin(start) : $coin"
		echo "aiten : $aiten_san"
		echo "---"
		echo "exit : /ten coin"
	fi

}

function ten_env() {
	limit_reset_at=`date --iso-8601=seconds -d '1 days ago'`
	ten_su=`echo $data|jq -r .ten_su`
	ten_bool=`echo $data|jq -r .ten`
	ten_card=`echo $data|jq -r .ten_card`
	aiten=`echo $data|jq -r .aiten`
	ten_delete=`echo $data|jq -r .ten_delete`
	ten_post=`echo $data|jq -r .ten_post`
	ten_get=`echo $data|jq -r .ten_get`
	ten_at=`echo $data|jq -r .ten_at`
	ten_at_n=`date --iso-8601=seconds`
}

function ten_env_check() {
	if { [ $ten_su -eq 0 ] && [ "$ten_bool" = "true" ] } || { [ $aiten -eq 0 ] && [ "$ten_bool" = "true" ] } || [ -z "$ten_su" ] || [ -z "$aiten" ];then
		user_env
		ten_env
	fi
}

function ten_yak_shutdown() {
	unset card
	case $ten_char in
		EMY)
			card=1
			;;
		KOS)
			card=2
			;;
		CHI)
			card=3
			;;
		AIT)
			card=4
			;;
		OYZ)
			card=5
			;;
		IKY)
			card=6
			;;
		AKM)
			card=7
			;;
		KUY)
			card=8
			;;
		AW*)
			card=9
			;;
		AHK)
			card=10
			;;
		IKT)
			card=11
			;;
		AAM)
			card=12
			;;
		OSZ)
			card=13
			;;
		CHO)
			card=14
			;;
		ETU)
			card=86
			if [ `ten_skill $ten_char` = false ];then
				unset card
			fi
			;;
		ETW)
			card=89
			if [ `ten_skill $ten_char` = false ];then
				unset card
			fi
			;;
		IKU)
			card=95
			if [ `ten_skill $ten_char` = false ];then
				unset card
			fi
			;;
		IIK)
			card=121
			if [ `ten_skill $ten_char` = false ];then
				unset card
			fi
			;;
		OUY)
			card=29
			if [ `ten_skill $ten_char` = false ];then
				unset card
			fi
			;;
		AIK)
			card=33
			if [ `ten_skill $ten_char` = false ];then
				unset card
			fi
			;;
		IIK)
			card=46
			if [ `ten_skill $ten_char` = false ];then
				unset card
			fi
			;;
		ACH)
			card=60
			if [ `ten_skill_yui $ten_char` = false ];then
				unset card
			fi
			if [ `ten_skill $ten_char` = false ];then
				unset card
			fi
			;;
		YUI)
			card=36
			if [ `ten_skill $ten_char` = false ];then
				unset card
			fi
			;;
		AIS)
			card=22
			if [ `ten_skill_yui $ten_char` = false ];then
				unset card
			fi
			;;
		TUY)
			card=64
			if [ `ten_skill $ten_char` = false ];then
				unset card
			fi
			;;
		EKS)
			card=67
			if [ `ten_skill_yui $ten_char` = false ];then
				unset card
			fi
			if [ `ten_skill $ten_char` = false ];then
				unset card
			fi
			;;
		IOU)
			card=69
			if [ `ten_skill_yui $ten_char` = false ];then
				unset card
			fi
			if [ `ten_skill $ten_char` = false ];then
				unset card
			fi
			;;
		ACC)
			card=76
			if [ `ten_skill_yui $ten_char` = false ];then
				unset card
			fi
			if [ `ten_skill $ten_char` = false ];then
				unset card
			fi
			;;
		AAC)
			card=77
			if [ `ten_skill_yui $ten_char` = false ];then
				unset card
			fi
			if [ `ten_skill $ten_char` = false ];then
				unset card
			fi
			;;
		AEK)
			card=78
			if [ `ten_skill_yui $ten_char` = false ];then
				unset card
			fi
			if [ `ten_skill $ten_char` = false ];then
				unset card
			fi
			;;
	esac
	ten_su=$((ten_su + ${card}00))
	if [ $card -ne 0 ];then
		echo "last : +${card}00"
	fi
}

function ten_shutdown(){
	if [ -z "$1" ];then 
		shut_opt=7
	else
		shut_opt=$1
	fi
	if [ $ten_kai -ge $shut_opt ];then

		all_data=`curl -sL "$host/users?itemsPerPage=3000"`
		ten_data=`echo $all_data|jq ".|sort_by(.ten_su)|reverse|.[]|select(.ten_su != 0)"`
		echo shutdown
		echo user : $handle
		echo ten :	$ten_su
		echo aiten :	$((aiten + ten_su))
		tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"ten_kai\":$ten_kai, \"ten_su\":$ten_su, \"ten\": false, \"token\":\"$token\", \"ten_at\" : \"$ten_at_n\", \"aiten\": $((aiten + ten_su))}" -s $host/users/$uid`

		ten_u_tmp=`echo $ten_data|jq -s`
		ten_n_tmp=`echo $ten_u_tmp|jq "length"`

		for ((i=0;i<$ten_n_tmp;i++))
		do
			u_a=`echo $ten_u_tmp|jq -r ".[$i].username"`
			u_s=`echo $ten_u_tmp|jq -r ".[$i].ten_su"`
			if [ $i -eq 0 ] && [ $ten_su -ge $u_s ];then
				echo win !
				tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"password\":\"$pass\"}" -s $host/cards`
				card=`echo $tmp|jq -r .card`
				card_url=`echo $tmp|jq -r .url`
				cp=`echo $tmp|jq -r .cp`
				echo "[card]"
				echo "id : $card"
				echo "cp : $cp"

				if [ $model = "true" ];then
					echo "---"
					echo "ai[model] status up!"
					if [ $(($RANDOM % 2)) -eq 0 ];then
						model_critical=$((model_critical + 1))
						json_model="{\"model_critical\":$model_critical, \"token\":\"$token\"}"
						echo "critical : ${model_critical}%"
					else
						model_critical_d=$((model_critical_d + 10))
						json_model="{\"model_critical_d\":$model_critical_d, \"token\":\"$token\"}"
						echo "critical_d : ${model_critical_d}%"
					fi
					tmp=`curl -X PATCH -H "Content-Type: application/json" -d "$json_model" -s $host/users/$uid`
				fi

			fi
			echo "---"
			echo "user : $u_a"
			echo "ten : $u_s"
		done
		exit
	fi
}

function card_post() {
	j=`echo $host_card_json|jq ".[]|select(.id == $card)"`
	img=`echo $j|jq -r .img`

	if [ $card -eq 30 ];then
		cten=${card}0
		old_ten_char=AAA
	else
		old_ten_char=`echo $j|jq -r .ten`
		cten=${card}00
	fi
	desc="+$cten"
	
	if [ -z $img ] || [ "$img" = "null" ];then
		exit
	fi
	ten_yak_check $ten_char
	title=`echo $j|jq -r .h`
	title="[${title}]"

	if [ $card -eq 36 ];then
		if [ "`card_yui_check`" = "true" ];then
			if [ "`moon_check`" = "true" ];then
				cten=${card}00
				body=`repeat $rr; echo "🌓 +10000"`
				img="bafkreieh2j3nbnetmux5xaid7iefv2vfgsjwkx5bx66ce6h35rq2oebo54"
				desc="+$cten (+${card_yui_ten})"
				title="月見(新月/満月)"
				title="[${title}・技]"
			else
				cten=${card}00
				body=`repeat $rr; echo "⚡ +1000"`
				img="bafkreieh2j3nbnetmux5xaid7iefv2vfgsjwkx5bx66ce6h35rq2oebo54"
				desc="+$cten (+${card_yui_ten})"
				title=`echo $j|jq -r .h`
				title="[${title}・技]"
			fi
		fi
	fi

	if [ $card -eq 89 ];then
		if [ "`card_kyoku_check`" = "false" ];then
			desc="+$cten (secret command -> /card kyoku)"
		fi
		if [ "`card_kyoku_check`" = "true" ];then
			cten=${card}00
			body=`repeat $rr; echo "⚡ +8900 +900"`
			img="bafkreihgubbbwcsvpl6hj5h4ijfzqy5yyqpvjsqkry4rtjs7rcjjqzun5a"
			desc="+$cten (+${card_kyoku_ten})"
			title=`echo $j|jq -r .h`
			title="[${title}・極]"
		fi
		if [ "`card_kyoku_check`" = "origin" ];then
			cten=${card}00
			body=`repeat $rr; echo "⚡⚡ +8900 +900 +1500"`
			img="bafkreihgubbbwcsvpl6hj5h4ijfzqy5yyqpvjsqkry4rtjs7rcjjqzun5a"
			desc="+$cten (+${card_kyoku_ten})"
			title=`echo $j|jq -r .h`
			title="[${title}・極]"
		fi
	fi

	if [ $card -eq 22 ];then
		if [ "`card_son_check 22`" = "true" ];then
			cten=${card}00
			body=`repeat $rr; echo "🔸 +2200"`
			img="bafkreiatrky4ilyvdt6gib33obof6rdrvqyt363z5wrjg6b5nzn6sgqsge"
			desc="+$cten (+${card_yui_ten})"
			title=`echo $j|jq -r .h`
			title="[${title}・技]"
		fi
	fi

	if [ $card -eq 60 ] || [ $card -eq 14 ];then
		if [ `card_chou_check` -ne 0 ];then
			cten=${card}00
			card_chou_check=`card_chou_check`
			rr=$(($card_chou_check * 1400))
			body=`echo "⚡ +${rr}"`
			img=bafkreighntijp47dejknvtrxbqocsy542vgpxcb3zaqxpc2vc52hy7bkw4
			desc="+$cten (+${card_chou_ten})"
			title=`echo $j|jq -r .h`
			title="[${title}]"
		fi
		if [ $card -eq 14 ];then
			img="bafkreig7qapoudilekw6bxfkj3in3owjhh2v23rx7abbgnszvkxi5dqbly"
		fi
	fi

	if [ $card -eq 76 ];then
		if [ "`card_yui_check`" = "true" ];then
			cten=${card}00
			card_chou_check=`card_chou_check`
			body=`echo "⚡ +???"`
			img=bafkreicmeuljtkl3jx4toudpuxagvjpdcgflhuwhbe3vh4e4fnlruawfyy
			desc="+$cten (+???)"
			title=`echo $j|jq -r .h`
			title="[${title}]"
		fi
	fi

	if [ $card -eq 77 ];then
		if [ "`card_yui_check`" = "true" ];then
			cten=${card}00
			card_chou_check=`card_chou_check`
			body=`echo "⚡ +???"`
			img="bafkreiarpxioqr5ulnwvukin6qrv5gyyymsggv255oc7wmfedsqpah4qcy"
			desc="+$cten (+???)"
			title=`echo $j|jq -r .h`
			title="[${title}]"
		fi
	fi

	if [ $card -eq 78 ];then
		if [ "`card_yui_check`" = "true" ];then
			cten=${card}00
			body=`echo "⚡ +???"`
			img="bafkreicbiujlv6hiluzc5db25j5phg7u2m2pu5h4qinxnpizq226n4hbae"
			desc="+$cten (+???)"
			title=`echo $j|jq -r .h`
			title="[${title}]"
		fi
	fi

	if [ $card -eq 9 ] && [ $model_attack -ge 1 ] && [ $model = "true" ] && [ $model_rr = "true" ];then
		cten=${card}00
		model_ten=$((model_attack * 10))
		body=`echo "🎮 x${model_ten}"`
		img="bafkreibrrikzsexsktw3xov2jts7zfwusnjnhjudqryj5v4flffpf3hxaq"
		desc="+$cten (x${model_ten})"
		title=`echo $j|jq -r .h`
		title="[${title}]"
	fi

	if [ $card -eq 2 ] && [ $model_mode -ge 1 ] && [ $model = "true" ] && [ $model_rr = "true" ];then
		cten=${card}00
		model_ten=$((model_mode * 10))
		body=`echo "🎮 x${model_ten}"`
		img="bafkreigosm3kxxkgyoxxapufcxn2uulqnj2lgrwsfccimmwafhulztqrhu"
		desc="+$cten (x${model_ten})"
		title=`echo $j|jq -r .h`
		title="[${title}]"
	fi

	if [ $card -eq 3 ] && [ $model_skill -ge 1 ] && [ $model = "true" ] && [ $model_rr = "true" ];then
		cten=${card}00
		model_ten=$((model_skill * 10))
		body=`echo "🎮 x${model_ten}"`
		img="bafkreiagpsr6dcr3zs3365yesm5deydlalarojbdx3fhbadbz64gznanzu"
		desc="+$cten (x${model_ten})"
		title=`echo $j|jq -r .h`
		title="[${title}]"
	fi

	if [ $card -eq 7 ] && [ $model_limit -ge 1 ] && [ $model = "true" ] && [ $model_rr = "true" ];then
		cten=${card}00
		model_ten=$((model_limit * 10))
		body=`echo "🎮 x${model_ten}"`
		img="bafkreianbnrsuerymlddh3lsxqzp7h33aifj5owofme34q2ilhliuippze"
		desc="+$cten (x${model_ten})"
		title=`echo $j|jq -r .h`
		title="[${title}]"
	fi

	link="https://card.syui.ai/${username}"
	text=`echo "$title +${cten}\n$body\nten : $ten_su\n$ten_kai : $old_ten_char ---> $ten_char $ten_yak_ok"`
	tmp_atr=`$atr reply-og "$text" --cid $cid --uri $uri --cid-root $cid_b --uri-root $uri_b --img $img --title "$title" --description "$desc" --link $link`
	ten_shutdown
}

function ten_plus() {
	ten_shutdown
	ten_kai=$((ten_kai + 1))
	ten_su=$((ten_su + $1))

	if [ $((RANDOM % 6)) -eq 0 ];then
		model_rr=true
	else
		model_rr=false
	fi
	if [ $card -eq 9 ] && [ $model_attack -ge 1 ] && [ $model = "true" ] && [ $model_rr = "true" ];then
		card_yui_ten=$((card * 100 * 10 * $model_attack))
		ten_su=$((card_yui_ten + ten_su))
	fi

	if [ $card -eq 2 ] && [ $model_mode -ge 1 ] && [ $model = "true" ] && [ $model_rr = "true" ];then
		card_yui_ten=$((card * 100 * 10 * $model_mode))
		ten_su=$((card_yui_ten + ten_su))
	fi

	if [ $card -eq 3 ] && [ $model_skill -ge 1 ] && [ $model = "true" ] && [ $model_rr = "true" ];then
		card_yui_ten=$((card * 100 * 10 * $model_skill))
		ten_su=$((card_yui_ten + ten_su))
	fi

	if [ $card -eq 7 ] && [ $model_limit -ge 1 ] && [ $model = "true" ] && [ $model_rr = "true" ];then
		card_yui_ten=$((card * 100 * 10 * $model_limit))
		ten_su=$((card_yui_ten + ten_su))
	fi

	if [ $card -eq 22 ];then
		if [ "`card_son_check 22`" = "true" ];then
			rr=$(($RANDOM % 6 + 1))
			card_yui_ten=$((2200 * rr))
			ten_su=$((card_yui_ten + ten_su))
		fi
	fi

	if [ $card -eq 36 ];then
		if [ "`card_yui_check`" = "true" ];then
			if [ "`moon_check`" = "true" ];then
				rr=$(($RANDOM % 5 + 1))
				card_yui_ten=$((10000 * rr))
				ten_su=$((card_yui_ten + ten_su))
			else
				rr=$(($RANDOM % 5 + 1))
				card_yui_ten=$((1000 * rr))
				ten_su=$((card_yui_ten + ten_su))
			fi
		fi
	fi

	if [ $card -eq 89 ];then
		if [ "`card_kyoku_check`" = "true" ];then
			rr=$(($RANDOM % 5 + 1))
			card_kyoku_ten=$((9800 * rr))
			ten_su=$((card_kyoku_ten + ten_su))
		fi
		if [ "`card_kyoku_check`" = "origin" ];then
			rr=$(($RANDOM % 7 + 1))
			card_kyoku_ten=$((11300 * rr))
			ten_su=$((card_kyoku_ten + ten_su))
		fi
	fi

	if [ $card -eq 60 ] || [ $card -eq 14 ];then
		if [ `card_chou_check` -ne 0 ];then
			card_chou_check=`card_chou_check`
			rr=$(($card_chou_check * 2400))
			ten_su=$((rr + ten_su))
		fi
	fi

	if [ $card -eq 76 ];then
		if [ "`card_yui_check`" = "true" ];then
			rr=$(($RANDOM % 10000 + 700))
			ten_su=$((rr + ten_su))
		fi
	fi

	if [ $card -eq 77 ];then
		if [ "`card_yui_check`" = "true" ];then
			rr=$(($RANDOM % 20000 + 700))
			ten_su=$((rr + ten_su))
		fi
	fi

	if [ $card -eq 78 ];then
		if [ "`card_yui_check`" = "true" ];then
			rr=$(($RANDOM % 30000 + 700))
			ten_su=$((rr + ten_su))
		fi
	fi

	ten_char

	char_a=`echo $ten_char|cut -b 1`
	char_b=`echo $ten_char|cut -b 2`
	char_c=`echo $ten_char|cut -b 3`

	if [ "$char_a" = "A" ] && [ "$char_b" = "A" ] && [ "$char_c" = "A" ];then
		ten_char=OSZ
	fi
	if [ "$char_a" = "A" ] && [ "$char_b" = "A" ];then
		ten_char=EMY
	fi
	if [ "$char_a" = "A" ] && [ "$char_b" = "I" ];then
		ten_char=KUY
	fi
	if [ $card -eq 1 ] && [ $ran_cm -eq 0 ];then
		ten_char=IKY
	fi
	if [ $card -eq 1 ] && [ $ran_cm -eq 1 ];then
		ten_char=KOS
	fi
	if [ $card -eq 2 ] && [ $ran_cm -eq 0 ];then
		ten_char=AWZ
	fi
	if [ $card -eq 3 ] && [ $ran_cm -eq 0 ];then
		ten_char=AIT
	fi
	if [ $card -eq 5 ] && [ $ran_cm -eq 0 ];then
		ten_char=AAM
	fi
	if [ $card -eq 7 ] && [ $ran_cm -eq 0 ];then
		ten_char=AAA
	fi
	if [ $card -eq 7 ] && [ $ran_cm -eq 1 ];then
		ten_char=ACC
	fi
	if [ $card -eq 12 ] && [ $ran_cm -eq 0 ];then
		ten_char=OSZ
	fi
	if [ $card -eq 29 ] && [ $ran_cm -eq 0 ];then
		ten_char=OSZ
	fi
	if [ $card -eq 36 ] && [ $ran_cm -eq 0 ];then
		ten_char=IKT
	fi
	if [ $card -eq 14 ] && [ $((RANDOM % 2)) -eq 1 ];then
		ten_char=ACH
	fi
	if [ $card -eq 36 ] && [ $((RANDOM % 2)) -eq 1 ];then
		ten_char=CHO
	fi
	if [ $card -eq 13 ] && [ $((RANDOM % 2)) -eq 1 ];then
		ten_char=AIS
	fi
	if [ $card -eq 46 ] && [ $((RANDOM % 2)) -eq 1 ];then
		ten_char=YUI
	fi
	if [ $card -eq 67 ] && [ $((RANDOM % 3)) -eq 1 ];then
		ten_char=IIK
	fi
	if [ $card -eq 76 ] && [ $((RANDOM % 2)) -eq 1 ];then
		ten_char=AAC
	fi
	if [ $card -eq 77 ] && [ $((RANDOM % 3)) -eq 1 ];then
		ten_char=AEK
	fi

	ten_yak_check $ten_char

	tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"ten_post\": \"$ten_char\", \"ten_kai\":$ten_kai,\"ten_su\":$ten_su, \"token\":\"$token\"}" -s $host/users/$uid`

	#if [ $ran_z -eq 1 ] && [ $card -ne 0 ] && [ -n "$card" ];then
	if [ `$((RANDOM % 5))` -eq 1 ] && [ $card -eq 1 ] && [ "`card_ar_check`" = "false" ];then
		echo "$ten_kai : $ten_su ---> $ten_char $ten_yak_ok"
		skill=3d
		st=3d
		cp=${card}00
		cp=$(($RANDOM % 1200 + 200))
		echo "[card] ---> 20%"
		echo "id:${card}"
		echo "status: ${st}"
		echo "skill:${skill}"
		tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$card,\"status\":\"$st\",\"cp\":$cp,\"password\":\"$pass\",\"skill\":\"$skill\"}" -s $host/cards`
	fi

	if [ $card -ne 0 ] && [ -n "$card" ];then
		card_post
	else
		echo "$ten_kai : $ten_su ---> $ten_char $ten_yak_ok"
		ten_shutdown
		#ten_data_reset
	fi
	exit
}

function ten_main() {
	ten_shutdown
	ten_kai=$((ten_kai + 1))
	ten_su=$((ten_su - $1))
	old_ten_char=$ten_char
	ten_char
	ten_yak_check $ten_char
	echo "$ten_kai : $ten_su ---> $ten_char $ten_yak_ok"
	tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"ten_post\": \"$ten_char\", \"ten_kai\":$ten_kai,\"ten_su\":$ten_su, \"token\":\"$token\"}" -s $host/users/$uid`
	echo "$ten_kai : $ten_su"
	#ten_data_reset
	exit
}

function ten_check() {
	if [ $ten_kai -ge 7 ];then
		ten_shutdown
		exit
	fi
}

function ten_yak() {
	if [ $ten_kai -ge 7 ];then
		ten_shutdown
		exit
	fi

	char_a=`echo $ten_post|cut -b 1`
	char_b=`echo $ten_post|cut -b 2`
	char_c=`echo $ten_post|cut -b 3`

	case $ten_post in

		EMY)
			card=1
			ten_plus ${card}00
			;;
		KOS)
			card=2
			ten_plus ${card}00
			;;
		CHI)
			card=3
			ten_plus ${card}00
			;;
		AIT)
			card=4
			ten_plus ${card}00
			;;
		OYZ)
			card=5
			ten_plus ${card}00
			;;
		IKY)
			card=6
			ten_plus ${card}00
			;;
		AKM)
			card=7
			ten_plus ${card}00
			;;
		KUY)
			card=8
			ten_plus ${card}00
			;;
		AW*)
			card=9
			ten_plus ${card}00
			;;
		AHK)
			card=10
			ten_plus ${card}00
			;;
		IKT)
			card=11
			ten_plus ${card}00
			;;
		AAM)
			card=12
			ten_plus ${card}00
			;;
		OSZ)
			card=13
			ten_plus ${card}00
			;;
		CHO)
			card=14
			ten_plus ${card}00
			;;
		ETU)
			card=86
			if `ten_skill $ten_post`;then
				ten_plus ${card}00
			fi
			;;
		ETW)
			card=89
			if `ten_skill $ten_post`;then
				ten_plus ${card}00
			fi
			;;
		IKU)
			card=95
			if `ten_skill $ten_post`;then
				ten_plus ${card}00
			fi
			;;
		IIK)
			card=121
			if `ten_skill $ten_post`;then
				ten_plus ${card}00
			fi
			;;
		OUY)
			card=29
			if `ten_skill $ten_post`;then
				ten_plus ${card}00
			fi
			;;
		AAA)
			card=30
			if `ten_skill $ten_post`;then
				ten_plus 300
			fi
			;;
		AIK)
			card=33
			if `ten_skill $ten_post`;then
				ten_plus ${card}00
			fi
			;;
		AIS)
			card=22
			if `ten_skill_yui $ten_post`;then
				ten_plus ${card}00
			fi
			;;
		YUI)
			card=36
			if `ten_skill $ten_post`;then
				ten_plus ${card}00
			fi
			;;
		ACH)
			card=60
			if `ten_skill_yui $ten_post`;then
				ten_plus ${card}00
			fi
			if `ten_skill $ten_post`;then
				ten_plus ${card}00
			fi
			;;
		TUY)
			card=64
			if `ten_skill $ten_post`;then
				ten_plus ${card}00
			fi
			;;
		IIK)
			card=46
			if `ten_skill $ten_post`;then
				ten_plus ${card}00
			fi
			;;
		EKS)
			card=67
			if `ten_skill_yui $ten_post`;then
				ten_plus ${card}00
			fi
			if `ten_skill $ten_post`;then
				ten_plus ${card}00
			fi
			;;
		IOU)
			card=69
			if `ten_skill_yui $ten_post`;then
				ten_plus ${card}00
			fi
			if `ten_skill $ten_post`;then
				ten_plus ${card}00
			fi
			;;
		ACC)
			card=76
			if `ten_skill_yui $ten_post`;then
				ten_plus ${card}00
			fi
			if `ten_skill $ten_post`;then
				ten_plus ${card}00
			fi
			;;
		AAC)
			card=77
			if `ten_skill_yui $ten_post`;then
				ten_plus ${card}00
			fi
			if `ten_skill $ten_post`;then
				ten_plus ${card}00
			fi
			;;
		AEK)
			card=78
			if `ten_skill_yui $ten_post`;then
				ten_plus ${card}00
			fi
			if `ten_skill $ten_post`;then
				ten_plus ${card}00
			fi
			;;
	esac

	unset card

	if [ "$ten_post" = "AAA" ];then
		echo "[揃] +100"
		ten_plus 100
	fi

	if [ "$char_a" = "A" ] && [ "$char_b" = "I" ];then
		echo "[名] +150"
		ten_plus 150
	fi

	if [ "$char_a" = "$char_b" ] && [ "$char_c" = "$char_b" ];then
		echo "[揃] +100"
		ten_plus 100
	fi

	if [ "$char_a" = "$char_b" ];then
		echo "[通] +50"
		ten_plus 50
	fi

	case $ten_post in
		*)
			echo "[空] -300"
			ten_main 300
			;;
	esac
}

function ten_delete_get() {
	if [ $ten_kai -ge 7 ];then
		exit
	fi
	char_a=`echo $ten_post|cut -b 1`
	char_b=`echo $ten_post|cut -b 2`
	char_c=`echo $ten_post|cut -b 3`
	ten_kai=$((ten_kai + 1))
	old_ten_char=$ten_char
	case $sub_option in
		1)
			ten_char_one
			ten_char=`echo "${char_b}\n${char_c}\n${ten_char_one}"|head -n 3|sort|tr -d '\n'`
			;;
		2)
			ten_char_one
			ten_char=`echo "${char_a}\n${char_c}\n${ten_char_one}"|head -n 3|sort|tr -d '\n'`
			;;
		3)
			ten_char_one
			ten_char=`echo "${char_a}\n${char_b}\n${ten_char_one}"|head -n 3|sort|tr -d '\n'`
			;;
		all|a|*)
			ten_char
			;;
	esac
	if [ ${#ten_char} -eq 1 ];then
		ten_char=AA${ten_char}
	fi
	if [ ${#ten_char} -eq 2 ];then
		ten_char=A${ten_char}
	fi
	ten_yak_check $ten_char
	tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"ten_post\": \"$ten_char\", \"ten_kai\":$ten_kai, \"token\":\"$token\"}" -s $host/users/$uid`
	ten_yak_check $ten_char
	echo "$ten_kai : $ten_su ---> $ten_char $ten_yak_ok $miss"

	ten_yak_check $ten_char
	if [ -n "$ten_yak_ok" ] && [ $ten_kai -ge 7 ];then
		ten_yak_shutdown
	fi
}

case "$option" in
	reset*)
		user_env
		ten_user_reset
		ten_data_reset
		exit
		;;
	pay)
		$card_pay $handle $did $cid $uri
		exit
		;;
	coin)
		$card_coin $handle $did $cid $uri
		exit
		;;
	bit*)
		coin_env
		exit
		;;
	aicoin)
		$card_aicoin $handle $did $cid $uri
		exit
		;;
	stop|close)
		user_env
		ten_env
		ten_user_stop
		exit
		;;
	y*)
		ten_yaku
		exit
		;;
	u*)
		ten_data_reset
		exit
		;;
	h*|"")
		echo "$help_body"
		exit
		;;
esac

user_env

case "$option" in
	p*)
		ten_env
		ten_env_check
		ten_yak
		;;
	d*)
		ten_env
		ten_env_check
		ten_yak_check $ten_char
		ten_delete_get
		;;
	start)
		ten_char
		ten_start
		exit
		;;
	coin_com)
		;;
	*)
		echo "no option"
		exit
		;;
esac

if [ "$option" = "coin_com" ];then
	case $sub_option in
		start)
			if [ "$coin_open" = "true" ];then
				echo currently open
				exit
			fi
			$card_coin $handle $did $cid $uri
			exit
			;;
		exit|close)
			if [ "$coin_open" = "false" ];then
				echo currently close
				exit
			fi
			$card_coin $handle $did $cid $uri
			exit
			;;
		bit)
			coin_env
			exit
			;;
		*)
			echo no option
			exit
			;;
	esac
fi

ten_shutdown

exit

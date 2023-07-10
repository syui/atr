#!/bin/zsh

case $OSTYPE in
	darwin*)
		alias date="/opt/homebrew/bin/gdate"
		;;
esac

card_pay=$HOME/.config/atr/scpt/card_pay.zsh
atr=$HOME/.cargo/bin/atr
host=https://api.syui.ai
host_card=https://card.syui.ai/json/card.json
host_card_json=`curl -sL $host_card`
n_cid=$HOME/.config/atr/txt/tmp_notify_cid.txt
f_cfg=$HOME/.config/atr/txt/tmp_ten_config.txt
handle=$1
did=$2
username=`echo $1|cut -d . -f 1`
cid=$3
uri=$4

if [ ! -f $f_cfg ];then
	echo $host_card_json |jq -r ".[]|select(.ten != null)|.ten" |tr -d '\n' >! $f_cfg
fi

if [ -f $f_cfg ];then
	nn=`cat $f_cfg|wc -c`
fi

pass=`cat $HOME/.config/atr/api_card.json|jq -r .password`
token=`cat $HOME/.config/atr/api_card.json|jq -r .token`

function ten_yak() {
	unset ran_a
	unset ran_b
	unset ran_c
	unset ten_new
	unset ten_yaku

	ran_a=$(($RANDOM % nn))
	ran_b=$(($RANDOM % nn))
	ran_c=$(($RANDOM % nn))
	
	ten_new=0

	char_a=`cat $f_cfg| cut -c $ran_a`
	char_b=`cat $f_cfg| cut -c $ran_b`
	char_c=`cat $f_cfg| cut -c $ran_c`
	ten_char=`echo "${char_a}\n${char_b}\n${char_c}"|head -n 3|sort|tr -d '\n'`
	if [ ${#ten_char} -eq 0 ];then
		ten_char=AAA
	fi
	if [ ${#ten_char} -eq 1 ];then
		ten_char=AA${ten_char}
	fi
	if [ ${#ten_char} -eq 2 ];then
		ten_char=A${ten_char}
	fi

	char_a=`echo $ten_char|cut -b 1`
	char_b=`echo $ten_char|cut -b 2`
	char_c=`echo $ten_char|cut -b 3`

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
		*)
			card=0
			;;
	esac

	ten_new=${card}00

	if [ $ten_new -eq 0 ];then
		ten_new=0
	else
		ten_yaku="[$ten_char]"
	fi

	if [ "$ten_char" = "AAA" ];then
		ten_new=100
	fi

	if [ "$char_a" = "A" ] && [ "$char_b" = "I" ] && [ $ten_new -ne 0 ];then
		ten_new=150
	fi

	if [ "$char_a" = "$char_b" ] && [ $ten_new -ne 0 ];then
		ten_new=50
	fi

	echo "[$i] $ten_su $ten_yaku+$ten_new"
	ten_su=$((ten_su + ten_new))
}

function user_env() {
	all_data=`curl -sL "$host/users?itemsPerPage=3000"`
	ten_data=`echo $all_data|jq ".|sort_by(.ten_su)|reverse|.[]|select(.ten_su != 0)"`
	data=`echo $all_data|jq ".[]|select(.username == \"$username\")"`
	uid=`echo $data|jq -r .id`
	aiten=`echo $data|jq -r .aiten`
	ten_post=`echo $data|jq -r .ten_post`
	ten_bool=`echo $data|jq -r .ten`
	day_at=`date +"%Y%m%d"`
	nd=`date +"%Y%m%d" -d '1 days ago'`
	ten_at_n=`date --iso-8601=seconds`
	limit_reset_at=`date --iso-8601=seconds -d '1 days ago'`
	d=`date +"%Y-%m-%d"`
	ten_at=`echo $data|jq -r .ten_at`
	ten_at=`date -d "$ten_at" +"%Y-%m-%d"`
	ten_kai=`echo $data|jq -r .ten_kai`
	if [ "$d" = "$ten_at" ];then
		echo "limit aiten"
		exit
	fi
	ten_kai=`echo $data|jq -r .ten_kai`
}

function ten_shutdown(){
	ten_kai=0
	all_data=`curl -sL "$host/users?itemsPerPage=3000"`
	ten=`echo $((ten_su + 200))`
	ten_su=$ten
	aiten=`echo $((aiten + ten_su))`
	echo "+100"
	echo "---"
	echo user : $handle
	echo ten :	$ten
	echo aiten :	
	tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"ten_kai\":$ten_kai, \"ten_su\":$ten_su, \"ten\": false, \"token\":\"$token\", \"ten_at\" : \"$ten_at_n\", \"aiten\": $aiten}" -s $host/users/$uid`
}

user_env

for ((i=1;i<=7;i++))
do
	ten_yak
done

ten_shutdown

exit

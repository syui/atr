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
atr=$HOME/.cargo/bin/atr
host=https://api.syui.ai
host_card=https://card.syui.ai/json/card.json
host_card_json=`curl -sL $host_card`
n_cid=$HOME/.config/atr/txt/tmp_notify_cid.txt
f_cfg=$HOME/.config/atr/txt/tmp_ten_config.txt

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
ten_kai=0

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

function card_yui_check() {
	data_user_card=`curl -sL "$host/users/$uid/card?itemsPerPage=3000"`
	card_yui_check=`echo $data_user_card|jq -r ".[]|select(.card == 47)"`
	if [ -n "$card_yui_check" ];then
		echo true
	else
		echo false
	fi
}

function ten_yak_check() {
	unset ten_yak_ok
	case "$1" in
		OUY|AIK|YUI)
			if `ten_skill $1`;then
				export ten_yak_ok="☑"
			fi
			;;
		EMY|KOS|CHI|AIT|OYZ|IKY|AKM|KUY|AW*|AHK|IKT|AAM|OSZ|CHO|AAA|AA*|AI*|YUI)
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
	if [ -z "$ten_yak_ok" ] && [ $ran_first -eq 1 ];then
		ten_char=EMY
	fi

	if [ -n "$ten_old_yak" ];then
		ten_char=$ten_old_yak
	fi

	ten_yak_check $ten_char

	if [ -z "$ten_yak_ok" ];then
		if `ten_skill YUI`;then
			card=36
			ten_char=YUI
			export ten_yak_ok="☑"
		else
			unset card
		fi
	fi

	##test
	#card=36
	#ten_char=YUI
	#export ten_yak_ok="☑"

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
	echo $text_one
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
	ten_post=`echo $data|jq -r .ten_post`
	ten_bool=`echo $data|jq -r .ten`
	day_at=`date +"%Y%m%d"`
	nd=`date +"%Y%m%d" -d '1 days ago'`
	ten_at_n=`date --iso-8601=seconds`
	limit_reset_at=`date --iso-8601=seconds -d '1 days ago'`
	d=`date +"%Y-%m-%d"`
	ten_at=`echo $data|jq -r .ten_at`
	ten_at=`date -d "$ten_at" +"%Y-%m-%d"`
	if [ "$d" = "$ten_at" ] && [ "$handle" != "syui.ai" ];then
		echo "limit aiten"
		exit
	fi
	ten_kai=`echo $data|jq -r .ten_kai`
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
			cten=${card}00
			body=`repeat $rr; echo "⚡ +1000"`
			img="bafkreieh2j3nbnetmux5xaid7iefv2vfgsjwkx5bx66ce6h35rq2oebo54"
			desc="+$cten (+${card_yui_ten})"
			title=`echo $j|jq -r .h`
			title="[${title}・技]"
		fi
	fi

	link="https://card.syui.ai/${username}"
	text=`echo "$title +${cten}\n$body\nten : $ten_su\n$ten_kai : $old_ten_char ---> $ten_char $ten_yak_ok"`
	tmp_atr=`$atr reply-og "$text" --cid $cid --uri $uri --img $img --title "$title" --description "$desc" --link $link`
	ten_shutdown
}

function ten_plus() {
	ten_shutdown
	ten_kai=$((ten_kai + 1))
	ten_su=$((ten_su + $1))

	if [ $card -eq 36 ];then
		if [ "`card_yui_check`" = "true" ];then
			rr=$(($RANDOM % 5 + 1))
			card_yui_ten=$((1000 * rr))
			ten_su=$((card_yui_ten + ten_su))
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
	if [ $card -eq 12 ] && [ $ran_cm -eq 0 ];then
		ten_char=OSZ
	fi
	if [ $card -eq 29 ] && [ $ran_cm -eq 0 ];then
		ten_char=OSZ
	fi
	if [ $card -eq 36 ] && [ $ran_cm -eq 0 ];then
		ten_char=IKT
	fi
	if [ $card -eq 13 ];then
		ten_char=EMY
	fi
	ten_yak_check $ten_char

	tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"ten_post\": \"$ten_char\", \"ten_kai\":$ten_kai,\"ten_su\":$ten_su, \"token\":\"$token\"}" -s $host/users/$uid`

	if [ $ran_z -eq 1 ] && [ $card -ne 0 ] && [ -n "$card" ];then
		echo "$ten_kai : $ten_su ---> $ten_char $ten_yak_ok"
		skill=ten
		cp=${card}00
		cp=$(($RANDOM % 1200 + 200))
		echo "[card] ---> 14%"
		echo "id:${card}"
		echo "skill:${skill}"
		tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$card,\"status\":\"normal\",\"cp\":$cp,\"password\":\"$pass\",\"skill\":\"$skill\"}" -s $host/cards`
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
		YUI)
			card=36
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
		ten_yak
		;;
	d*)
		ten_env
		ten_yak_check $ten_char
		ten_delete_get
		;;
	start)
		ten_char
		ten_start
		exit
		;;
	*)
		echo "no option"
		exit
		;;
esac

ten_shutdown
exit

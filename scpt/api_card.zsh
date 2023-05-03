#!/bin/zsh

case $OSTYPE in
	darwin*)
		alias date="/opt/homebrew/bin/gdate"
		;;
esac

function battle_raid(){
	boss_cp=50000
	f_raid=$HOME/.config/atr/txt/card_raid.txt
	f_raid_user=$HOME/.config/atr/txt/card_raid_user.txt

	if [ ! -f $f_raid ];then
		echo "$boss_cp" >! $f_raid
	fi

	if [ `cat $f_raid` -eq 0 ];then
		echo "[boss]"
		echo "shutdown"
		exit
	fi

	if [ $updated_at -ge $d ];then
		if [ "$updated_at" = "$d" ] && { [ "$updated_at_m" = "$day_m" ] || [ "$updated_at_m" = "$day_mm" ] || [ "$updated_at_m" = "$day_mmm" ] };then
			exit
		else
			echo "limit battle"
			exit
		fi
	else
		data_u=`curl -sL "$url/users/$uid/card?itemsPerPage=2000"`
		cp_i=`echo $data_u |jq -r "sort_by(.cp) | reverse|.[0].cp"`
		skill=`echo $data_u |jq -r "sort_by(.cp) | reverse|.[0].skill"`
		ss=$(($RANDOM % 2))
		if [ "$skill" = "critical" ] && [ $ss -eq 1 ];then
			cp_i=$((cp_i + cp_i))
		fi

		if [[ "$cp_i" =~ ^[0-9]+$ ]]; then
		else
			echo error
			exit
		fi
		cp_b=`cat $f_raid`
		cp_bb=`expr $cp_b - $cp_i`
		echo "[raid battle]"
		if [ "$skill" = "critical" ] && [ $ss -eq 1 ];then
			echo "⚡  $cp_i vs $cp_b ---> $cp_bb"
		else
			echo "$cp_i vs $cp_b ---> $cp_bb"
		fi

		if [ `cat $f_raid` -eq 0 ];then
			echo shutdown boss
			exit
		fi

		s=normal
		ss=$(($RANDOM % 10))
		if [ $ss -eq 1 ];then
			card=`echo $(($RANDOM % 15))`
		else
			card=0
		fi

		if [ $cp_i -gt $cp_bb ];then
			echo "win!"
			echo "0" >! $f_raid
			card=`echo $(($RANDOM % 15))`
		else
			echo $cp_bb >! $f_raid
			echo $uid >> $f_raid_user
		fi

		if [ $card -eq 0 ];then
			cp=`echo $(($RANDOM % 100 + 50))`
		else
			cp=`echo $(($RANDOM % 500 + 200))`
			s=$(($RANDOM % 2))
			if [ $s -eq 1 ];then
				s=super
				plus=$(($RANDOM % 500 + 300))
				cp=$((cp + plus))
			fi
		fi

		tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$card,\"status\":\"$s\",\"cp\":$cp,\"password\":\"$pass\"}" -s $url/cards`
		card=`echo $tmp|jq -r .card`
		card_url=`echo $tmp|jq -r .url`
		cp=`echo $tmp|jq -r .cp`
		echo "---"
		echo "[card]"
		echo "id : ${card}"
		echo "cp : ${cp}"

		tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"updated_at\":\"$updated_at_n\",\"token\":\"$token\"}" -s $url/users/$uid`
	fi
	exit
}

function l_cards() {
	data_card=`curl -sL "$url/users/$old_id/card?itemsPerPage=2000"`
	nn=`echo $data_card|jq length`
	nn=$((nn - 1))
	for ((ii=0;ii<=$nn;ii++))
	do
		card=`echo $data_card|jq -r ".[$ii].card"`
		s=`echo $data_card|jq -r ".[$ii].status"`
		cp=`echo $data_card|jq -r ".[$ii].cp"`
		tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$card,\"status\":\"$s\",\"cp\":$cp,\"password\":\"$pass\"}" -sL $url/cards`
	done
}

d=`date +"%Y%m%d"`
nd=`date +"%Y%m%d" -d '1 day'`
username=`echo $1|cut -d . -f 1`
#username=$1
url=https://api.syui.ai
url_user_all="$url/users?itemsPerPage=2000"
f=$HOME/.config/atr/scpt/t.webp
pass=`cat $HOME/.config/atr/api_card.json|jq -r .password`
token=`cat $HOME/.config/atr/api_card.json|jq -r .token`
if [ -z "$1" ];then
	exit
fi

data_tmp=`curl -sL $url_user_all`
data=`echo "$data_tmp"|jq ".[]|select(.username == \"$username\")"`
data_did=`echo "$data_tmp"|jq ".[]|select(.did == \"$2\")"`

if [ -z "$data" ];then
	#echo "we are currently experiencing problems and are suspending new registrations"
	#echo "---"
	#echo "現在、問題が発生しており、新規登録を停止しています"
	#exit
	if [ -n "$data_did" ];then
		old_user=`echo $data_did|jq -r .username`
		old_id=`echo $data_did|jq -r .id`
		echo https://card.syui.ai/$old_user
	fi
	data=`curl -X POST -H "Content-Type: application/json" -d "{\"username\":\"$username\",\"password\":\"$pass\",\"did\":\"$2\"}" -s "$url/users"`
	echo $data|jq -r .username
	if [ -n "$data_did" ];then
		uid=`echo $data|jq -r ".id"|tail -n 1`
		l_cards
	fi
fi
next=`echo $data|jq -r .next`
if [ "$next" = "null" ];then
	echo null error
fi

uid=`echo $data|jq -r ".id"`
delete=`echo $data|jq -r ".delete"`
did=`echo $data|jq -r ".did"`

if [ "$delete" = "true" ];then
	echo change account $did
	exit
fi

# battle
updated_at=`echo $data|jq -r .updated_at`
updated_at_m=`date -d "$updated_at" +"%H%M"`
updated_at_n=`date --iso-8601=seconds`
updated_at=`date -d "$updated_at" +"%Y%m%d"`
day_m=`date +"%H%M"`
day_mm=`date +"%H%M" -d "-1 min"`
day_mmm=`date +"%H%M" -d "-2 min"`

if [ "$3" = "-raid" ] || [ "$3" = "-r" ];then
	battle_raid $1 $2
fi

if [ "$3" = "-b" ];then
	if [ $updated_at -ge $d ];then
		if [ "$updated_at" = "$d" ] && { [ "$updated_at_m" = "$day_m" ] || [ "$updated_at_m" = "$day_mm" ] || [ "$updated_at_m" = "$day_mmm" ] };then
			exit
		else
			echo "limit battle"
			exit
		fi
	else
		id_all=`curl -sL "https://api.syui.ai/users?itemsPerPage=2000"|jq ".[]|.id"`
		id_n=`echo "$id_all"|wc -l`
		id_nr=$(($RANDOM % $id_n))
		r=`echo "$id_all"| awk "NR==$id_nr"`

		if [ "$id_all" = "null" ];then
			r=2
		fi

		if [ 0 -eq $id_n ] || [ 0 -eq $r ];then
			r=2
		fi
		if [ -z "$id_n" ] || [ -z "$r" ];then
			r=2
		fi

		data_u=`curl -sL "$url/users/$uid/card?itemsPerPage=2000"`
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

		data_u=`curl -sL "$url/users/$r/card?itemsPerPage=2000"`
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
			echo "[card]"
			echo id : $card
			echo cp : $cp
			t=`echo $tmp|jq -r .card`

			# 自分との戦いで勝利した場合
			if [ $r -eq $uid ];then
				card=`echo $(($RANDOM % 15))`
				cp=`echo $(($RANDOM % 300 + 200))`
				s=$(($RANDOM % 2))
				if [ $s -eq 1 ];then
					s=super
					plus=$(($RANDOM % 500 + 500))
					cp=$((cp + plus))
				else
					s=normal
				fi
				if [ $card -eq 13 ];then
					plus=$(($RANDOM % 1200 + 800))
					cp=$((cp + plus))
				fi
				tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$card,\"status\":\"$s\",\"cp\":$cp,\"password\":\"$pass\"}" -s $url/cards`
				echo "
          .
        =%:
    -##*%#:
   -%=  .*%.
   =%    -%:
   *%*:.:#%=
 .+##=*###+.
				"
				card=`echo $tmp|jq -r .card`
				card_url=`echo $tmp|jq -r .url`
				cp=`echo $tmp|jq -r .cp`
				echo "[card]"
				echo "id : ${card}"
				echo "cp : ${cp}"
			fi
		fi

		tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"updated_at\":\"$updated_at_n\",\"token\":\"$token\"}" -s $url/users/$uid`

	fi
	exit
fi

if [ "$3" = "ai" ];then
	data=`echo "$data_tmp"|jq ".[]|select(.username == \"ai\")"`
	next=`echo $data|jq -r .next`
	d=`date +"%Y%m%d"`
	if [ $next -gt $d ];then
		exit
	fi
	tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":2,\"password\":\"$pass\"}" -s $url/cards`
	## ai card plus
	#tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"password\":\"$pass\"}" -s $url/cards`
	card=`echo $(($RANDOM % 15))`
	cp=`echo $(($RANDOM % 300 + 200))`
	s=$(($RANDOM % 2))
	if [ $s -eq 1 ];then
		s=super
		plus=$(($RANDOM % 200 + 500))
		cp=$((cp + plus))
	else
		s=normal
	fi
	if [ $card -eq 13 ];then
		plus=$(($RANDOM % 500 + 800))
		cp=$((cp + plus))
	fi
	tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$card,\"status\":\"$s\",\"cp\":$cp,\"password\":\"$pass\"}" -s $url/cards`
	## ai card plus

	echo "\nthx! $username"
	echo "\n"
	echo "
          .
        =%:
    -##*%#:
   -%=  .*%.
   =%    -%:
   *%*:.:#%=
 .+##=*###+.
"
	card=`echo $tmp|jq -r .card`
	card_url=`echo $tmp|jq -r .url`
	cp=`echo $tmp|jq -r .cp`
	echo "[card]"
	echo "id : ${card}"
	echo "cp : ${cp}"
	echo "\nhttps://card.syui.ai/ai"
	t=`echo $tmp|jq -r .card`
	tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"next\":\"$nd\",\"token\":\"$token\"}" -s $url/users/2`
	exit
fi

if [ $next -gt $d ];then
	if [ "$updated_at" = "$d" ] && { [ "$updated_at_m" = "$day_m" ] || [ "$updated_at_m" = "$day_mm" ] || [ "$updated_at_m" = "$day_mmm" ] };then
		exit
	else
		echo limit 1 day
		echo "next : $nd"
		exit
	fi
fi

tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"password\":\"$pass\"}" -s $url/cards`
card=`echo $tmp|jq -r .card`
card_url=`echo $tmp|jq -r .url`
cp=`echo $tmp|jq -r .cp`
skill=`echo $tmp|jq -r .skill`
echo "[card]"
echo id : $card
echo cp : $cp
if [ "$skill" != "normal" ];then
	echo skill : $skill
fi
t=`echo $tmp|jq -r .card`
tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"next\":\"$nd\",\"token\":\"$token\"}" -s $url/users/$uid`
#next=`echo $tmp|jq -r .next`
#echo next : $next

#f=$HOME/.config/atr/scpt/t.webp
#curl -sL -o $f https://card.syui.ai/card/card_${t}.webp

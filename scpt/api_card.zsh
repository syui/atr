#!/bin/zsh

# raid-boss-admin
cfg=$HOME/.config/atr/scpt/card_config.json
# {
# "raid_admin":"yui.bsky.social",
#	"raid_time": "",
#	"raid_card": ""
# }

case $OSTYPE in
	darwin*)
		alias date="/opt/homebrew/bin/gdate"
		;;
esac

function user_data(){
	u=`echo $data|jq -r .username`
	id=`echo $data|jq -r .id`
	did=`echo $data|jq -r .did`
	next=`echo $data|jq -r .next`
	d=`date +"%Y%m%d"`
	updated_at=`echo $data|jq -r .updated_at`
	updated_at=`date -d "$updated_at" +"%Y-%m-%d"`
	next_at=`date -d "$next -1 day" +"%Y-%m-%d"`
	echo "user : $u"
	echo "id : $id"
	echo "$did"
	echo "card : $next_at"
	echo "battle : $updated_at"
	echo "boss : $raid_cp"
}

function ascii_moji_a() {
echo "
⠀⠈⠀⠀⠀⠀⠈⠀⠀⠀⠁⠀⣠⠈⠀⠀⠀⠁⠀⠀⠈⠀⠀⠀⠁⠀
⠈⠀⠀⠂⠁⠀⠀⠄⠀⠠⠀⣰⡯⣷⡀⠀⢀⠀⢀⠠⠀⠀⡀⠄⠀⠀
⠀⠄⠀⢀⠀⠀⠄⠀⣠⢴⣼⣳⣟⣗⡷⣦⣄⡀⠀⠀⠀⠀⠀⠀⠀⢀
⢀⠀⠀⠀⠀⠀⣠⢾⣽⣻⡺⠷⠳⠯⢯⣗⣯⣟⣦⠀⠀⠐⠀⠀⠄⠀
⠀⠀⠀⠁⠀⣸⢽⣻⡺⠊⠀⢀⠀⠀⠀⠈⢳⣗⣯⢷⠀⠀⠄⠀⠀⠀
⠐⠈⠀⠀⠀⣿⢽⣳⠁⡀⠄⠀⠀⠀⠂⠀⠀⣳⢯⣟⡇⠀⠀⠀⠈⠀
⠀⠀⢀⠀⠈⣯⣟⣾⡀⠀⠀⠀⠐⠀⠀⠄⠀⣺⡽⣞⡇⠀⠀⠁⠀⠀
⠈⠀⠀⠀⢠⣟⣞⣷⣳⣀⠀⠂⠀⠀⠄⢀⡴⣯⢯⣟⣆⠀⠀⠂⠀⠂
⠠⠀⠐⢀⣟⣞⣷⣳⣻⣞⡷⡦⣦⢦⡶⡯⡿⣽⢽⢾⢽⣆⠀⠠⠀⠀
⠀⠀⠀⠚⠉⠉⠁⠉⠑⠳⢯⡿⣽⣽⡽⠽⠛⠉⠉⠉⠙⠙⠀⠀⠀⡀
⠀⠁⠀⠀⠄⠈⠀⠀⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⢀⠠⠀⠈⠀⠀
"
}

function ascii_moji_b() {
echo "
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠
⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣷⡀
⠀⠀⠀⠀⠀⣠⢴⣼⣿⣿⣿⣿⣦⣄⡀
⠀⠀⠀⣠⢾⣿⣿⡺⠷⠳⠯⢯⣿⣿⣿⣦
⠀⠀⣸⣿⣿⡺⠊⠀⠀⠀⠀⠀⠈⢳⣿⣿⢷
⠀⠀⣿⣿⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡇
⠀⠀⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⣺⣿⣿⡇
⠀⢠⣿⣿⣿⣳⣀⠀⠀⠀⠀⠀⠀⡴⣿⣿⣿⣆
⠀⣿⣿⣿⣿⣿⣿⡷⡦⣦⢦⡶⣿⣿⣿⣿⣿⣿⣆
⠚⠉⠉⠁⠉⠑⠳⢯⣿⣿⣿⡽⠽⠛⠉⠉⠉⠙⠙"
}

function yui_card() {
	card=$1
	cp=$2
	data_uu=`curl -sL "$url/users/$uid/card?itemsPerPage=2000"`
	card_check=`echo $data_uu|jq -r ".[]|select(.card == $card)"`
	if [ -n "$card_check" ];then
		echo "you already have"
		exit
	fi
	tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$card,\"status\":\"super\",\"cp\":$cp,\"password\":\"$pass\",\"skill\":\"critical\"}" -s $url/cards`
	card=`echo $tmp|jq -r .card`
	cp=`echo $tmp|jq -r .cp`
	ascii_moji_b
	echo "---"
	echo "[card]"
	echo "id : ${card}"
	echo "cp : ${cp}"
}

function moji_mode_card() {
	card=$1
	cp=$2
	skills=$3
	data_uu=`curl -sL "$url/users/$uid/card?itemsPerPage=2000"`
	card_check=`echo $data_uu|jq -r ".[]|select(.card == $card)"`
	if [ -n "$card_check" ];then
		echo "you already have"
		exit
	fi
	tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$card,\"status\":\"super\",\"cp\":$cp,\"password\":\"$pass\",\"skill\":\"$skill\"}" -s $url/cards`
	card=`echo $tmp|jq -r .card`
	cp=`echo $tmp|jq -r .cp`
	ascii_moji_b
	echo "---"
	echo "[card]"
	echo "id : ${card}"
	echo "cp : ${cp}"
	echo "skill : ${skill}"
	sleep 2
}

function user_card(){
	id=$1
	data=`curl -sL "$url/users/$id"`
	u=`echo $data|jq -r .username`
	data_u=`curl -sL "$url/users/$id/card?itemsPerPage=2000"`
	cp_i=`echo $data_u |jq -r "sort_by(.cp) | reverse|.[0].cp"`
	cp_ii=`echo $data_u |jq -r "sort_by(.cp) | reverse|.[1].cp"`
	cp_iii=`echo $data_u |jq -r "sort_by(.cp) | reverse|.[2].cp"`
	boss_l=`curl -sL "https://api.syui.ai/users/$id/card?itemsPerPage=2550"|jq ".[]|.cp"|sed 's/^0$/10000/g'|tr "\n" "+"`
	boss_cp=$((${boss_l/%?/}))
	owner=`curl -sL card.syui.ai/json/card.json|jq -r ".[]|select(.owner == \"$u\")|.id,.h"|tr -d '\n'`
	if [ "$u" = "null" ];then
		echo no id
		exit
	fi
	echo "user : $u"
	echo "[card]"
	echo "cp : $cp_i"
	echo "cp : $cp_ii"
	echo "cp : $cp_iii"
	echo "[boss]"
	echo "cp : $boss_cp"
	if [ -n "$owner" ];then
		echo "owner : $owner"
	fi
}

function battle_raid(){
	f_raid_user=$HOME/.config/atr/txt/card_raid_user.txt
	f_raid_start_cp=$HOME/.config/atr/txt/card_raid_start_cp.txt
	f_raid_start_time=$HOME/.config/atr/txt/card_raid_start_time.txt
	boss_cp=$(($RANDOM % 100000))
	boss_cp=$((boss_cp + 30000))

	if [ -n "$raid_boss_admin" ] && [ "$raid_run" = "true" ];then
		boss_user=`echo $raid_boss_admin | cut -d . -f 1`
		boss_user_bsky=$raid_boss_admin
		boss_cp=100000
		boss_id=$raid_boss_id
		boss_card=23
		boss_card_win=24
	fi

	if [ -n "$raid_boss_admin" ] && [ ! -f $f_raid ] && [ "$raid_run" = "true" ];then
		boss_l=`curl -sL "https://api.syui.ai/users/${boss_id}/card?itemsPerPage=2550"|jq ".[]|.cp"|sed 's/^0$/10000/g'|tr "\n" "+"`
		boss_cp=$((${boss_l/%?/}))
	fi

	if [ ! -f $f_raid ];then
		raid_start=`date +"%H:%M"`
		echo "$boss_cp" >! $f_raid
		echo "$boss_cp" >! $f_raid_start_cp
		echo "$raid_start" >! $f_raid_start_time
	fi

	if [ -f $f_raid_start_time ];then
		raid_start=`cat $f_raid_start_time`
		raid_time=`date -d "$raid_start 3 min" +"%H:%M"`
	fi

	if [ -f $f_raid_start_cp ];then
		raid_start_cp=`cat $f_raid_start_cp`
	fi

	if [ `cat $f_raid` -eq 1 ];then
		echo "[boss]${boss_user}"
		echo "win"
		exit
	fi

	if [ `cat $f_raid` -eq 0 ];then
		echo "[boss]"
		echo "shutdown"
		exit
	fi

	# time attack
	rr=`date +"%H:%M"`
	if [ -n "$raid_boss_admin" ] && [ "$boss_user" = "$boss_user_time" ] && [ "$raid_run" = "true" ];then
		echo "time : $rr ---> $raid_time"
	fi

	if [ "$raid_time" = "$rr" ] && [ -n "$raid_boss_admin" ] && [ "$boss_user" = "$boss_user_time" ] && [ "$raid_run" = "true" ];then
		echo "boss win!"
		cp_b=`cat $f_raid`
		echo "cp : $cp_b"
		echo 1 >! $f_raid
		body=`echo "\n[card]\nid : $boss_card_win\ncp : 0"`
		sleep 3
		tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$boss_id,\"card\":$boss_card_win,\"status\":\"super\",\"cp\":0,\"password\":\"$pass\"}" -s $url/cards`
		tmp=`$HOME/.cargo/bin/atr @ ${boss_user_bsky} -p "$body"`
	fi

	if [ $raid_at -ge $d ];then
		echo "limit battle"
	else
		data_u=`curl -sL "$url/users/$uid/card?itemsPerPage=2000"`
		cp_i=`echo $data_u |jq -r "sort_by(.cp) | reverse|.[0].cp"`
		skill=`echo $data_u |jq -r "sort_by(.cp) | reverse|.[0].skill"`
		ss=$(($RANDOM % 2))
		ss_post=$(($RANDOM % 2))
		#ss_post=$(($RANDOM % 10))
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
		if [ -n "$boss_user_bsky" ];then
			echo "@${boss_user_bsky}\nhttps://card.syui.ai/${boss_user}"
		fi
		if [ "$skill" = "critical" ] && [ $ss -eq 1 ];then
			echo "⚡  $cp_i vs $cp_b ---> $cp_bb"
		elif [ "$skill" = "post" ] && [ $ss_post -eq 1 ];then
			cp_post=`$HOME/.cargo/bin/atr pro $1 -p`
			cp_i=$((cp_i + cp_post))
			echo "🔥 $cp_i vs $cp_b ---> $cp_bb"
		elif [ "$skill" = "luck" ] && [ $ss_post -eq 1 ];then
			echo "✨ $cp_i vs $cp_b ---> $cp_bb"
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

		if [ 0 -ge $cp_bb ];then
			echo "win!"
			echo 0 >! $f_raid
			rm $cfg
			card=`echo $(($RANDOM % 15))`
			if [ -n "$raid_boss_admin" ];then
				body=`echo "\n[card]\nid : $boss_card\ncp : 0"`
				sleep 1
				tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$boss_id,\"card\":$boss_card,\"status\":\"super\",\"cp\":0,\"password\":\"$pass\"}" -s $url/cards`
				tmp=`$HOME/.cargo/bin/atr @ ${boss_user_bsky} -p "$body"`
				raid_end=`date +"%H:%M"`
				raid_body=`echo "[raid status]\n${boss_user_bsky}\ncp : $raid_start_cp\nstart/$raid_start\nend/$raid_end\nlast : $raid_last"`
				tmp=`$HOME/.cargo/bin/atr p "$raid_body"`
			else
				raid_end=`date +"%H:%M"`
				raid_body=`echo "[raid status]\ncp : $raid_start_cp\nstart/$raid_start\nend/$raid_end\nlast : $raid_last"`
				tmp=`$HOME/.cargo/bin/atr p "$raid_body"`
			fi
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

		if [ -n "$raid_boss_admin" ] && [ "$raid_run" = "true" ];then
			data_uu=`curl -sL "$url/users/$uid/card?itemsPerPage=2000"`
			card_check=`echo $data_uu|jq -r ".[]|select(.card == $raid_sp_card)"`
		fi

		if [ -n "$raid_boss_admin" ] && [ -z "$card_check" ] && [ "$raid_run" = "true" ];then
			sleep 1
			tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$raid_sp_card,\"status\":\"normal\",\"cp\":0,\"password\":\"$pass\"}" -s $url/cards`
			card=`echo $tmp|jq -r .card`
			card_url=`echo $tmp|jq -r .url`
			cp=`echo $tmp|jq -r .cp`
			echo "---"
			echo "[card]"
			echo "id : ${card}"
			echo "cp : ${cp}"
		fi

		if [ $cp_i -gt $cp_bb ];then
			tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"password\":\"$pass\"}" -s $url/cards`
			#tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$card,\"status\":\"$s\",\"cp\":$cp,\"password\":\"$pass\"}" -s $url/cards`
		else
			tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"password\":\"$pass\"}" -s $url/cards`
		fi

		card=`echo $tmp|jq -r .card`
		card_url=`echo $tmp|jq -r .url`
		cp=`echo $tmp|jq -r .cp`
		echo "---"
		echo "[card]"
		echo "id : ${card}"
		echo "cp : ${cp}"
		if [ "$s" = "critical" ] || [ "$s" = "luck" ] || [ "$s" = "post" ];then
			echo "skill : ${s}"
		fi

		if [ "$skill" = "luck" ] && [ $ss_post -eq 1 ];then
			tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"password\":\"$pass\"}" -s $url/cards`
			card=`echo $tmp|jq -r .card`
			card_url=`echo $tmp|jq -r .url`
			cp=`echo $tmp|jq -r .cp`
			echo "---"
			echo "[card]"
			echo "id : ${card}"
			echo "cp : ${cp}"
			if [ "$s" = "critical" ] || [ "$s" = "luck" ] || [ "$s" = "post" ];then
				echo "skill : ${s}"
			fi
		fi

		tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"raid_at\":\"$raid_at_n\",\"token\":\"$token\"}" -s $url/users/$uid`
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

url=https://api.syui.ai
cfg=$HOME/.config/atr/scpt/card_config.json
if [ -f $cfg ];then
	raid_run=`cat $cfg|jq -r .raid_run`
	raid_boss_admin=`cat $cfg|jq -r .raid_admin`
	boss_user_time=`cat $cfg|jq -r .raid_time | cut -d . -f 1`
	boss_user=`echo $raid_boss_admin | cut -d . -f 1`
	raid_boss_id=`curl -sL "$url/users?itemsPerPage=2000"|jq ".[]|select(.username == \"$boss_user\")"|jq -r .id`
	raid_sp_card=`cat $cfg|jq -r .raid_card`
fi

f_raid=$HOME/.config/atr/txt/card_raid.txt
raid_cp=`cat $f_raid`
d=`date +"%Y%m%d"`
nd=`date +"%Y%m%d" -d '1 day'`
username=`echo $1|cut -d . -f 1`
#username=$1
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
raid_last=$1

if [ -z "$data" ];then
	#echo "we are currently experiencing problems and are suspending new registrations"
	#echo "---"
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
raid_at=`echo $data|jq -r .raid_at`
raid_at=`date -d "$raid_at" +"%Y%m%d"`
raid_at_n=`date --iso-8601=seconds`
day_m=`date +"%H%M"`
day_mm=`date +"%H%M" -d "-1 min"`
day_mmm=`date +"%H%M" -d "-2 min"`
f_raid=$HOME/.config/atr/txt/card_raid.txt

# luck
luck=`echo $data|jq -r .luck`
luck_at=`echo $data|jq -r .luck_at`
luck_at=`date -d "$luck_at" +"%Y%m%d"`

if [ "$3" = "-raidstart" ] || [ "$3" = "raidstart" ] || [ "$3" = "raid-start" ];then
	if [ "$raid_boss_admin" = "$1" ] || [ "syui.ai" = "$1" ];then
		rm $f_raid
		echo "admin : $raid_boss_admin"
		echo "raid start!"
		cat $cfg|jq ".|= .+{\"raid_run\":true}" >! $cfg.b
		mv $cfg.b $cfg
	else
		echo no raid admin
	fi
	exit
fi

if [ "$3" = "-raidstop" ] || [ "$3" = "raidstop" ] || [ "$3" = "raid-stop" ];then
	if [ "syui.ai" = "$1" ];then
		echo 0 >! $f_raid
		echo "admin : $raid_boss_admin"
		echo "raid stop!"
	else
		echo no raid admin
	fi
	exit
fi

if [ "admin" = "`echo $3|cut -d = -f 1`" ];then
	if [ "syui.ai" = "$1" ] || [ "ai" = "$1" ];then
		echo "
		{
			\"raid_admin\":\"`echo $3|cut -d = -f 2`\",
			\"raid_time\": null,
			\"raid_card\": 25
		}" | jq . >! $cfg
			cat $cfg
	else
		echo no admin
	fi
	exit
fi

if [ "$3" = "-raid" ] || [ "$3" = "-r" ] || [ "$3" = "r" ];then
	battle_raid $1 $2
fi

if [ "$3" = "-u" ] || [ "$3" = "u" ];then
	user_data
	echo "---"
	user_card $uid
	exit
fi

if [[ "$3" =~ ^[0-9]+$ ]];then
	user_card $3
	exit
fi

if [ "$3" = "-a" ] || [ "$3" = "a" ];then
	ascii_moji_a
	exit
fi

if [ "$3" = "-aa" ] || [ "$3" = "aa" ];then
	ascii_moji_b
	exit
fi

if [ "$3" = "yui" ] || [ "$3" = "-yui" ];then
	yui_card 19 123
	exit
fi

if [ "$3" = "moji" ] || [ "$3" = "-moji" ];then
	echo "not open"
	exit
	plus=$(($RANDOM % 1000 + 400))
	cp=$((cp + plus))

	skill=$(($RANDOM % 2))
	if [ $skill -eq 1 ];then
		skill=critical
		plus=$(($RANDOM % 400))
		cp=$((cp + plus))
	else
		skill=normal
	fi

	skill=$(($RANDOM % 10))
	if [ $skill -eq 1 ];then
		skill=post
		plus=$(($RANDOM % 400))
		cp=$((cp + plus))
	else
		skill=normal
	fi

	moji_mode_card 27 $cp $skill

	exit
fi

if [ "$3" = "zen" ] || [ "$3" = "-zen" ];then
	yui_card 20 123
	exit
fi

if [ "$3" = "-b" ] || [ "$3" = "b" ];then
	if [ $updated_at -ge $d ];then
		if [ "$updated_at" = "$d" ] && { [ "$updated_at_m" = "$day_m" ] || [ "$updated_at_m" = "$day_mm" ] || [ "$updated_at_m" = "$day_mmm" ] };then
			echo "limit battle"
			exit
		else
			echo "limit battle"
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

		data_uu=`curl -sL "$url/users/$uid/card?itemsPerPage=2000"`
		data_u=`curl -sL "$url/users/$r/card?itemsPerPage=2000"`
		tt=`echo $data_uu|jq ".[].cp"|sort -n -r`
		ttt=`echo $data_u|jq ".[].cp"|sort -n -r`

		#echo $data_u|jq ".[].cp"
		nl=`echo $data_uu|jq length`
		if [ $nl -ge 3 ];then
			rs=$(($RANDOM % 3 + 1))
		else
			rs=$(($RANDOM % $nl + 1))
		fi

		#echo $data_u|jq ".[].cp"
		nll=`echo $data_u|jq length`
		rss=$(($RANDOM % $nll))
		if [ $nll -ge 3 ];then
			rss=$(($RANDOM % 3 + 1))
		else
			rss=$(($RANDOM % $nll + 1))
		fi
		cp_i=`echo $tt |awk "NR==$rs"`
		cp_b=`echo $ttt |awk "NR==$rss"`
		if [ -z "$cp_i" ];then
			echo "null error"
			exit
		fi
		if [ -z "$cp_b" ];then
			echo "null error"
			exit
		fi

		echo $tt | sed -n 1,3p
		echo "---"
		echo id : $r
		echo $ttt | sed -n 1,3p
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
			if [ -z "$card" ];then
				tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"password\":\"$pass\"}" -s $url/cards`
				card=`echo $tmp|jq -r .card`
				card_url=`echo $tmp|jq -r .url`
				cp=`echo $tmp|jq -r .cp`
			fi
			echo "[card]"
			echo id : $card
			echo cp : $cp
			t=`echo $tmp|jq -r .card`

			# ai vs i
			if [ $r -eq $uid ];then
				echo "$username vs $username"
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
				sleep 5
				tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$card,\"status\":\"$s\",\"cp\":$cp,\"password\":\"$pass\"}" -s $url/cards`
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

if [ "$3" = "ai" ] || [ "$3" = "-ai" ];then
	data=`echo "$data_tmp"|jq ".[]|select(.username == \"ai\")"`
	next=`echo $data|jq -r .next`
	if [ "$next" = "null" ];then
		echo "null error"
		exit
	fi
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

	skill=$(($RANDOM % 2))
	if [ $skill -eq 1 ];then
		skill=critical
		plus=$(($RANDOM % 400))
		cp=$((cp + plus))
	else
		skill=normal
	fi

	skill=$(($RANDOM % 10))
	if [ $skill -eq 1 ];then
		skill=post
		plus=$(($RANDOM % 400))
		cp=$((cp + plus))
	else
		skill=normal
	fi

	if [ $card -eq 13 ];then
		plus=$(($RANDOM % 500 + 800))
		cp=$((cp + plus))
	fi
	sleep 5
	tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$card,\"status\":\"$s\",\"cp\":$cp,\"password\":\"$pass\",\"skill\":\"$skill\"}" -s $url/cards`

	## ai card plus
	ascii_moji_b
	echo "\n[card]"
	echo "id : $card"
	echo "cp : $cp"
	if [ "$skill" = "critical" ] || [ "$skill" = "post" ] || [ "$skill" = "luck" ];then
		echo "skill : $skill"
	fi

	card=`echo $tmp|jq -r .card`
	card_url=`echo $tmp|jq -r .url`
	cp=`echo $tmp|jq -r .cp`
	t=`echo $tmp|jq -r .card`
	tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"next\":\"$nd\",\"token\":\"$token\"}" -s $url/users/2`
	exit
fi

if [ $next -gt $d ];then
	if [ "$updated_at" = "$d" ] && { [ "$updated_at_m" = "$day_m" ] || [ "$updated_at_m" = "$day_mm" ] || [ "$updated_at_m" = "$day_mmm" ] };then
		echo limit 1 day
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
if [ -z "$card" ];then
	tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"password\":\"$pass\"}" -s $url/cards`
	card=`echo $tmp|jq -r .card`
	card_url=`echo $tmp|jq -r .url`
	cp=`echo $tmp|jq -r .cp`
	skill=`echo $tmp|jq -r .skill`
fi

echo "[card]"
echo id : $card
echo cp : $cp
if [ "$skill" != "normal" ];then
	echo skill : $skill
fi
t=`echo $tmp|jq -r .card`
tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"next\":\"$nd\",\"token\":\"$token\"}" -s $url/users/$uid`

s=`echo $(($RANDOM % 10))`
luck_at_d=`date +"%Y%m%d"`
# luck day
if [ $luck -eq 7 ] && [ "$luck_at" = "$luck_at_d" ] && [ $s -eq 1 ];then
	skill=luck
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
	cp=$((cp + 100))
	sleep 2
	tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$card,\"status\":\"$s\",\"cp\":$cp,\"password\":\"$pass\", \"skill\": \"$skill\"}" -s $url/cards`
	card=`echo $tmp|jq -r .card`
	card_url=`echo $tmp|jq -r .url`
	cp=`echo $tmp|jq -r .cp`
	echo "[card]"
	echo "id : ${card}"
	echo "cp : ${cp}"
	echo "skill : ${skill}"
fi

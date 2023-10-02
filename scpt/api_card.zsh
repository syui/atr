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

# 1=handle, 2=did, 3=opt, 4=sub
fav_com=$HOME/.config/atr/scpt/api_fav.zsh

function user_data(){
	u=`echo $data|jq -r .username`
	id=`echo $data|jq -r .id`
	did=`echo $data|jq -r .did`
	next=`echo $data|jq -r .next`
	aiten=`echo $data|jq -r .aiten`
	ten_su=`echo $data|jq -r .ten_su`
	fav=`echo $data|jq -r .fav`
	d=`date +"%Y%m%d"`
	updated_at=`echo $data|jq -r .updated_at`
	updated_at=`date -d "$updated_at" +"%Y-%m-%d"`
	next_at=`date -d "$next -1 day" +"%Y-%m-%d"`
	echo "user : $u"
	echo "id : $id"
	echo "$did"
	echo "card : $next_at"
	echo "battle : $updated_at"
	#echo "boss : $raid_cp"
	echo "aiten : $aiten"
	echo "ten : $ten_su"
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

function study_card() {
	card=$1
	cp=$2
	s=normal
	skill=study
	author=$username
	count=1
	data_uu=`curl -sL "$url/users/$uid/card?itemsPerPage=3000"`
	card_check=`echo $data_uu|jq -r ".[]|select(.card == $card)"`
	if [ -n "$card_check" ];then
		echo "you already have"
		exit
	fi
	tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$card,\"status\":\"$s\",\"cp\":$cp,\"password\":\"$pass\",\"skill\":\"$skill\",\"author\":\"$author\",\"count\":$count}" -s $url/cards`
	card=`echo $tmp|jq -r .card`
	cp=`echo $tmp|jq -r .cp`
	ascii_moji_b
	echo "---"
	echo "[card]"
	echo "id : ${card}"
	echo "cp : ${cp}"
	echo "count : $count"
	echo "author : ${author}"
}

function field_card() {
	card=73
	cp=0
	s=field
	skill=field

	data_uu=`curl -sL "$url/users/$uid/card?itemsPerPage=3000"`
	card_check=`echo $data_uu|jq -r ".[]|select(.card == $card and .cp == $cp and .skill == \"field\")"`
	if [ -z "$card_check" ];then
		tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$card,\"status\":\"$s\",\"cp\":$cp,\"password\":\"$pass\",\"skill\":\"$skill\"}" -s $url/cards`
		card=`echo $tmp|jq -r .card`
		cp=`echo $tmp|jq -r .cp`
		ascii_moji_b
		echo "---"
		echo "[card]"
		echo "id : ${card}"
		echo "cp : ${cp}"
		echo "status : ${s}"
		echo "skill : ${skill}"
	fi

	cp=$1

	data_uu=`curl -sL "$url/users/$uid/card?itemsPerPage=3000"`
	card_check=`echo $data_uu|jq -r ".[]|select(.card == $card and .cp == $cp and .skill == \"field\")"`
	if [ -z "$card_check" ];then
		tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$card,\"status\":\"$s\",\"cp\":$cp,\"password\":\"$pass\",\"skill\":\"$skill\"}" -s $url/cards`
		card=`echo $tmp|jq -r .card`
		cp=`echo $tmp|jq -r .cp`
		ascii_moji_b
		echo "---"
		echo "[card]"
		echo "id : ${card}"
		echo "cp : ${cp}"
		echo "status : ${s}"
		echo "skill : ${skill}"
	else
		echo "you already have"
		exit
	fi
}

function yui_card_add() {
	card=$1
	cp=$2
	s=yui
	skill=yui
	data_uu=`curl -sL "$url/users/$uid/card?itemsPerPage=3000"`
	card_check=`echo $data_uu|jq -r ".[]|select(.card == $card)"`
	if [ -z "$card_check" ];then
		tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$card,\"status\":\"$s\",\"cp\":$cp,\"password\":\"$pass\",\"skill\":\"$skill\"}" -s $url/cards`
		card=`echo $tmp|jq -r .card`
		cp=`echo $tmp|jq -r .cp`
		#ascii_moji_b
		echo "---"
		echo "[card]"
		echo "id : ${card}"
		echo "cp : ${cp}"
		echo "status : ${s}"
		echo "skill : ${skill}"
	fi
}

function yui_card() {
	card=$1
	cp=$2
	s=yui
	skill=yui
	data_uu=`curl -sL "$url/users/$uid/card?itemsPerPage=3000"`
	card_check=`echo $data_uu|jq -r ".[]|select(.card == $card)"`
	if [ -n "$card_check" ];then
		echo "you already have"
		exit
	fi
	card_check=`echo $data_uu|jq -r ".[]|select(.card == 36)"`
	if [ -z "$card_check" ] && [ $card -eq 47 ];then
		echo "no yui card"
		exit
	fi
	tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$card,\"status\":\"$s\",\"cp\":$cp,\"password\":\"$pass\",\"skill\":\"$skill\"}" -s $url/cards`
	card=`echo $tmp|jq -r .card`
	cp=`echo $tmp|jq -r .cp`
	ascii_moji_b
	echo "---"
	echo "[card]"
	echo "id : ${card}"
	echo "cp : ${cp}"
	echo "status : ${s}"
	echo "skill : ${skill}"
}

function moji_mode_card() {
	card=$1
	cp=$2
	skills=$3
	s=$4
	data_uu=`curl -sL "$url/users/$uid/card?itemsPerPage=2000"`
	card_check=`echo $data_uu|jq -r ".[]|select(.card == $card)"`
	if [ -n "$card_check" ];then
		echo "you already have"
		exit
	fi
	tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$card,\"status\":\"$s\",\"cp\":$cp,\"password\":\"$pass\",\"skill\":\"$skill\"}" -s $url/cards`
	card=`echo $tmp|jq -r .card`
	cp=`echo $tmp|jq -r .cp`
	ascii_moji_b
	echo "---"
	echo "[card]"
	echo "id : ${card}"
	echo "cp : ${cp}"
	echo "status : ${s}"
	echo "skill : ${skill}"
	sleep 1
}

function egg_card() {
	card=39
	data_uu=`curl -sL "$url/users/$uid/card?itemsPerPage=2000"`
	card_check=`echo $data_uu|jq -r ".[]|select(.card == $card)"`
	if [ -n "$card_check" ];then
		echo "you already have, dragon"
		exit
	fi

	card=40
	cp=0
	data_uu=`curl -sL "$url/users/$uid/card?itemsPerPage=2000"`
	card_check=`echo $data_uu|jq -r ".[]|select(.card == $card)"`
	if [ -n "$card_check" ];then
		echo "you already have, egg"
		exit
	fi

	card=42
	cp=0
	data_uu=`curl -sL "$url/users/$uid/card?itemsPerPage=2000"`
	card_check=`echo $data_uu|jq -r ".[]|select(.card == $card)"`
	if [ -n "$card_check" ];then
		echo "you already have, nyan"
		exit
	fi

	#if [ "$book" != true ];then
	#	echo no book
	#	exit
	#fi

	tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$card,\"cp\":$cp,\"password\":\"$pass\"}" -s $url/cards`
	card=`echo $tmp|jq -r .card`
	cp=`echo $tmp|jq -r .cp`
	ascii_moji_b
	echo "---"
	echo "[card]"
	echo "id : ${card}"
	echo "cp : ${cp}"
}

function user_card(){
	id=$1
	data=`curl -sL "$url/users/$id"`
	u=`echo $data|jq -r .username`
	data_u=`curl -sL "$url/users/$id/card?itemsPerPage=2000"`
	cp_i=`echo $data_u |jq -r "sort_by(.cp) | reverse|.[0].cp"`
	cp_ii=`echo $data_u |jq -r "sort_by(.cp) | reverse|.[1].cp"`
	cp_iii=`echo $data_u |jq -r "sort_by(.cp) | reverse|.[2].cp"`
	data_u_card=`curl -sL "https://api.syui.ai/users/$id/card?itemsPerPage=3000"`
	boss_l=`echo $data_u_card|jq ".[]|.cp"|sed 's/^0$/10000/g'|tr "\n" "+"`
	boss_cp=$((${boss_l/%?/}))
	page_card=`curl -sL card.syui.ai/json/card.json`
	owner=`echo $page_card|jq -r ".[]|select(.owner == \"$u\")|.id,.h"|tr -d '\n'`
	pay_card=`echo $page_card|jq -r ".[]|select(.ten_skill == true)?|.id"`
	pay_card_n=`echo $pay_card|wc -l`
	for ((i=1;i<=$pay_card_n;i++))
	do
		t=`echo $pay_card|awk "NR==$i"`
		ten_card=`echo $data_u_card|jq ".[]|select(.card == $t)"`
		if [ -z "$ten_card" ];then
			out=${out}${t},
		fi
	done
	pay_card=`echo $page_card|jq -r ".[]|select(.ten_skill == true)?|.id,.h"|xargs -n2|tr '\n' ,`
	if [ "$u" = "null" ];then
		echo no id
		exit
	fi
	#echo "user : $u"
	echo "[card]"
	echo "cp : $cp_i"
	echo "cp : $cp_ii"
	echo "cp : $cp_iii"
	echo "[boss]"
	echo "cp : $boss_cp"
	if [ -n "$owner" ];then
		echo "owner : $owner"
	fi
	#echo "pay : $pay_card"
	echo "pay_no : $out"
}

function battle_raid(){
	f_raid_user=$HOME/.config/atr/txt/card_raid_user.txt
	f_raid_start_cp=$HOME/.config/atr/txt/card_raid_start_cp.txt
	f_raid_start_time=$HOME/.config/atr/txt/card_raid_start_time.txt
	boss_cp=$(($RANDOM % 100000))
	boss_cp=$((boss_cp + 80000))

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
		cid=`echo $data_u |jq -r "sort_by(.cp) | reverse|.[0].id"`
		skill=`echo $data_u |jq -r "sort_by(.cp) | reverse|.[0].skill"`
		ss=$(($RANDOM % 4))
		sss=$(($RANDOM % 3))
		ss_post=$(($RANDOM % 2))
		if [ "$skill" = "critical" ] && [ $ss -eq 1 ];then
			cp_i=$((cp_i + cp_i))
		fi
		if [ "$skill" = "dragon" ] && [ $sss -eq 1 ];then
			cp_i=$((cp_i + cp_i + cp_i))
		fi
		if [ "$skill" = "yui" ] && [ $ss -eq 1 ];then
			cp_i=$((cp_i + ten_su))
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
		elif [ "$skill" = "post" ] && [ $sss -eq 1 ];then
			cp_post=`$HOME/.cargo/bin/atr pro $1 -p`
			cp_i=$((cp_i + cp_post))
			cp_bb=$((cp_bb - cp_post))
			echo "🔥 $cp_i vs $cp_b ---> $cp_bb"
		elif [ "$skill" = "luck" ] && [ $ss_post -eq 1 ];then
			echo "✨ $cp_i vs $cp_b ---> $cp_bb"
		elif [ "$skill" = "dragon" ] && [ $sss -eq 1 ];then
			echo "🐉 $cp_i vs $cp_b ---> $cp_bb"
		elif [ "$skill" = "yui" ] && [ $ss -eq 1 ];then
			if [ $cid -eq $fav ];then
				echo "🔅 $cp_i vs $cp_b •*¨*•.¸¸✧  $cp_bb"
			else
				echo "🔅 $cp_i vs $cp_b ---> $cp_bb"
			fi
		else 
			echo "$cp_i vs $cp_b ---> $cp_bb"
		fi

		if [ `cat $f_raid` -eq 0 ];then
			echo shutdown boss
			exit
		fi

		s=normal
		ss=`echo $(($RANDOM % 10))`
		if [ $ss -eq 1 ];then
			card=`echo $(($RANDOM % 15))`
		else
			card=0
		fi

		if [ 0 -ge $cp_bb ];then
			echo "win!"
			echo 0 >! $f_raid
			card=`echo $(($RANDOM % 15))`
			if [ -n "$raid_boss_admin" ];then
				body=`echo "\n[card]\nid : $boss_card\ncp : 0"`
				sleep 1
				tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$boss_id,\"card\":$boss_card,\"status\":\"super\",\"cp\":0,\"password\":\"$pass\"}" -s $url/cards`
				tmp=`$HOME/.cargo/bin/atr @ ${boss_user_bsky} -p "$body"`
				raid_end=`date +"%H:%M"`
				raid_body=`echo "[raid status]\n${boss_user_bsky}\ncp : $raid_start_cp\nstart/$raid_start\nend/$raid_end\nlast : $raid_last"`
				tmp=`$HOME/.cargo/bin/atr p "$raid_body"`
				if [ "$raid_run" = "true" ];then
					rm $cfg
				fi
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
			s=`echo $(($RANDOM % 2))`
			if [ $s -eq 1 ];then
				s=super
				plus=$(($RANDOM % 500 + 300))
				cp=$((cp + plus))
			fi
		fi

		#if [ -n "$raid_boss_admin" ] && [ "$raid_run" = "true" ];then
		#	data_uu=`curl -sL "$url/users/$uid/card?itemsPerPage=2000"`
		#	card_check=`echo $data_uu|jq -r ".[]|select(.card == $raid_sp_card)"`
		#fi

		if [ -n "$raid_boss_admin" ] && [ -z "$card_check" ] && [ "$raid_run" = "true" ];then
			ss=`echo $(($RANDOM % 10))`
			if [ $ss -eq 1 ];then
				s=super
			fi
			tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$raid_sp_card,\"status\":\"$s\",\"cp\":0,\"password\":\"$pass\"}" -s $url/cards`
			card=`echo $tmp|jq -r .card`
			card_url=`echo $tmp|jq -r .url`
			cp=`echo $tmp|jq -r .cp`
			echo "---"
			echo "[card]"
			echo "id : ${card}"
			echo "cp : ${cp}"
			echo "status : ${s}"
		fi

		ran_s=`echo $((RANDOM % 1200))`
		if [ $ran_s -eq 0 ] || [ 0 -ge $cp_bb ];then
			thd=`echo $((RANDOM % 11 + 1))`
			skill=3d
			card_t=$thd
			card_check=`curl -sL "https://api.syui.ai/users/$uid/card?itemsPerPage=3000"|jq -r ".[]|select(.card == $card_t)|select(.skill == \"$skill\")"`
			card=$card_t
			cp=`echo $(($RANDOM % 1000 + 400))`
			st=3d

			if [ -z "$card_check" ];then
				echo "[new]"
				echo "id : $card_t"
				echo "cp : $cp"
				echo "status : $st"
				echo "skill : $skill"
				tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$card,\"status\":\"$st\",\"cp\":$cp,\"password\":\"$pass\",\"skill\":\"$skill\"}" -sL $url/cards`
			fi

			#if [ -n "$card_check" ];then
			#	card=68
			# card_t=$card
			# skill=normal
			#	st=super
			#	cp=0
			#	echo "[new]"
			#	echo "id : $card_t"
			#	echo "cp : $cp"
			#	echo "status : $st"
			#	echo "skill : $skill"
			#	tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$card,\"status\":\"$st\",\"cp\":$cp,\"password\":\"$pass\",\"skill\":\"$skill\"}" -sL $url/cards`
			#fi

		fi

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

function battle_server(){
	rr=`date +"%H%M"`
	a_team=bluesky
	b_team=mastodon
	f_server=$HOME/.config/atr/txt/card_server.txt
	f_server_user_at=$HOME/.config/atr/txt/card_server_user_at.txt
	f_server_user_ap=$HOME/.config/atr/txt/card_server_user_ap.txt
	f_server_ap=$HOME/.config/atr/txt/card_server_ap.txt
	f_server_at=$HOME/.config/atr/txt/card_server_at.txt
	f_server_start_time=$HOME/.config/atr/txt/card_server_start_time.txt

	if [ `cat $f_server` -eq 1 ];then
		echo shutdown server battle
		exit
	fi

	if [ ! -f $f_server_start_time ];then
		server_start=`date +"%H%M"`
		echo "$server_start" >! $f_server_start_time
		echo 0 >! $f_server_at
		echo 0 >! $f_server_ap
	fi

	cp_ap=`cat $f_server_ap`
	cp_at=`cat $f_server_at`

	if [ -f $f_server_start_time ];then
		server_start=`cat $f_server_start_time`
		server_time=`date -d "$server_start 30 min" +"%H%M"`
	fi

	#echo "time:`date -d "$server_time" +"%H:%M"`"

	if [ $server_at -ge $d ];then
		echo "limit battle"
		exit
	fi

	data_u=`curl -sL "$url/users/$uid/card?itemsPerPage=4000"`
	fav_card=`echo $data_u|jq -r ".[]|select(.id == $fav)"`
	cid=$fav

	if [ -z "$fav_card" ];then
		echo "/fav <CID>"
		echo https://card.syui.ai/pr
		exit
	fi

	if [ ! -f $f_server_user_at ];then
		echo start >> $f_server_user_at
	fi
	if [ ! -f $f_server_user_ap ];then
		echo start >> $f_server_user_ap
	fi
	commit_user_at=`cat $f_server_user_at|tail -n 1`
	commit_user_ap=`cat $f_server_user_ap|tail -n 1`
	echo $username >> $f_server_user_at

	cp_i=`echo $fav_card|jq -r ".cp"`
	cid=`echo $fav_card|jq -r ".id"`
	cp_ii=$cp_i
	card_name=`echo $fav_card|jq -r ".card"`
	card_status=`echo $fav_card|jq -r ".status"`
	card_skill=`echo $fav_card|jq -r ".skill"`
	skill=$card_skill

	if [ "$skill" = "critical" ];then
		cp_i=$((cp_i + cp_i))
	fi
	if [ "$skill" = "dragon" ];then
		cp_i=$((cp_i * 3))
	fi
	if [ "$skill" = "yui" ];then
		cp_i=$((cp_i + ten_su))
	fi

	cp_all=$((cp_i + cp_at))
	if [ "$skill" = "critical" ];then
		echo "⚡  $cp_i ---> $cp_at"
	elif [ "$skill" = "post" ];then
		cp_post=`$HOME/.cargo/bin/atr pro $1 -p`
		cp_i=$((cp_i + cp_post))
		cp_all=$((cp_i + cp_at))
		echo "🔥 $cp_i ---> $cp_at"
	elif [ "$skill" = "luck" ];then
		echo "✨ $cp_i ---> $cp_at"
	elif [ "$skill" = "dragon" ];then
		echo "🐉 $cp_i ---> $cp_at"
	elif [ "$skill" = "yui" ];then
		if [ $cid -eq $fav ];then
			echo "🔅 $cp_i •*¨*•.¸¸✧  $cp_at"
		else
			echo "🔅 $cp_i ---> $cp_at"
		fi
	else
		echo "${cp_i} ---> $cp_at"
	fi

	echo $cp_all >! $f_server_at
	echo
	echo "[${a_team}] ${cp_all}"
	echo "┣ @${username}"
	echo "┗ @${commit_user_at}"
	echo
	echo "┏━ vs ━┛"
	echo
	echo "[${b_team}] ${cp_ap}"
	echo "┗ @${commit_user_ap}"
	#echo "[log]"
	#echo "${commit_user_at} --> ${cp_at}/$a_team"
	#echo "${cp_ap}/$b_team <-- ${commit_user_ap}"
	#echo "${username} --> $cp_all/$a_team"

	if [ $rr -gt $server_time ];then
		echo "----"
		echo "time up!"
		body="${cp_all}/${a_team} vs ${cp_ap}/${b_team}"
		tmp=`$HOME/.cargo/bin/atr p "$body"`
		echo 1 >! $f_server
		rm $f_server_start_time
		rm $f_server_at
		rm $f_server_ap
		mv $f_server_user_at $f_server_user_at.back
		mv $f_server_user_ap $f_server_user_ap.back
	fi

	echo "----"
	cp_plus=$(($RANDOM % 30 + 1))
	cp=$((cp_ii + cp_plus))
	body="level up!"
	echo "${body} ✧${cp}(+${cp_plus})"
	tmp=`curl -sL -X PATCH -H "Content-Type: application/json" -d "{\"cp\":$cp,\"token\":\"$token\"}" $url/cards/$fav`
	tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"server_at\":\"$server_at_n\",\"token\":\"$token\"}" -s $url/users/$uid`

	ran_s=`echo $((RANDOM % 1200))`
	if [ $ran_s -eq 0 ];then
		echo "----"
		thd=`echo $((RANDOM % 11 + 1))`
		skill=3d
		card_t=$thd
		card_check=`curl -sL "https://api.syui.ai/users/$uid/card?itemsPerPage=3000"|jq -r ".[]|select(.card == $card_t)|select(.skill == \"$skill\")"`
		card=$card_t
		cp=`echo $(($RANDOM % 1000 + 400))`
		st=3d

		if [ -z "$card_check" ];then
			echo "[new]"
			echo "id : $card_t"
			echo "cp : $cp"
			echo "status : $st"
			echo "skill : $skill"
			tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$card,\"status\":\"$st\",\"cp\":$cp,\"password\":\"$pass\",\"skill\":\"$skill\"}" -sL $url/cards`
		fi
	fi

	exit
}


function l_cards() {
	tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"aiten\":$old_aiten,\"token\":\"$token\"}" -s $url/users/$uid`
	data_card=`curl -sL "$url/users/$old_id/card?itemsPerPage=2000"`
	tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"delete\":true,\"token\":\"$token\"}" -s $url/users/$old_id`
	nn=`echo $data_card|jq length`
	nn=$((nn - 1))
	for ((ii=0;ii<=$nn;ii++))
	do
		card=`echo $data_card|jq -r ".[$ii].card"`
		s=`echo $data_card|jq -r ".[$ii].status"`
		cp=`echo $data_card|jq -r ".[$ii].cp"`
		skill=`echo $data_card|jq -r ".[$ii].skill"`
		tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$card,\"status\":\"$s\",\"cp\":$cp,\"password\":\"$pass\",\"skill\":\"$skill\"}" -sL $url/cards`
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
handle=$1
url_user_all="$url/users?itemsPerPage=2000"
f=$HOME/.config/atr/scpt/t.webp
pass=`cat $HOME/.config/atr/api_card.json|jq -r .password`
token=`cat $HOME/.config/atr/api_card.json|jq -r .token`
if [ -z "$1" ];then
	exit
fi
data_tmp=`curl -sL $url_user_all`
data=`echo "$data_tmp"|jq ".[]|select(.username == \"$username\")"`
data_did_check=`echo $data|jq -r .did`
data_did=`echo "$data_tmp"|jq ".[]|select(.did == \"$2\")"`
data_did_check_b=`echo $data_did|jq -r .did`
raid_last=$1

# user create (did)
if [ -n "$data" ] && [ -z "$data_did" ];then
	username=`echo $handle|tr '.' '-'`
	data=`curl -X POST -H "Content-Type: application/json" -d "{\"username\":\"$username\",\"password\":\"$pass\",\"did\":\"$2\",\"handle\": true}" -s "$url/users"`
	handle_change=true
	if [ -n "$data_did" ];then
		uid=`echo $data|jq -r ".id"|tail -n 1`
		l_cards
	fi
fi
next=`echo $data|jq -r .next`
fav=`echo $data|jq -r .fav`
aiten=`echo $data|jq -r .aiten`
ten_su=`echo $data|jq -r .ten_su`
if [ "$next" = "null" ];then
	echo null error
	exit
fi

# user create
if [ -z "$data" ];then
	if [ -n "$data_did" ];then
		old_user=`echo $data_did|jq -r .username`
		old_id=`echo $data_did|jq -r .id`
		old_aiten=`echo $data_did|jq -r .aiten`
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
	exit
fi

uid=`echo $data|jq -r ".id"`
delete=`echo $data|jq -r ".delete"`
did=`echo $data|jq -r ".did"`
handle_change=`echo $data|jq -r ".handle"`

# check did
if [ "$data_did_check" != "$2" ] && [ "$data_did_check_b" = "$2" ] && [ "$handle_change" = "true" ];then
	data=$data_did
	new_handle=`echo $data|jq -r .username`
	echo "handle : $username -> $new_handle"
	username=$new_handle
fi

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
server_at=`echo $data|jq -r .server_at`
server_at=`date -d "$server_at" +"%Y%m%d"`
server_at_n=`date --iso-8601=seconds`
day_m=`date +"%H%M"`
day_mm=`date +"%H%M" -d "-1 min"`
day_mmm=`date +"%H%M" -d "-2 min"`
f_raid=$HOME/.config/atr/txt/card_raid.txt

# luck
luck=`echo $data|jq -r .luck`
luck_at=`echo $data|jq -r .luck_at`
luck_at=`date -d "$luck_at" +"%Y%m%d"`
fav_cid=`echo $data|jq -r .fav`

# member
member=`echo $data|jq -r .member`
manga=`echo $data|jq -r .manga`
book=`echo $data|jq -r .book`
badge=`echo $data|jq -r .badge`

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

if [ "ap" = "`echo $3|cut -d = -f 1`" ];then
	echo activitypub mode
	b=`echo $3|cut -d = -f 2`
	case $b in
		true|false)
			data=`curl -X PATCH -H "Content-Type: application/json" -d "{\"token\":\"$token\",\"mastodon\":$b}" -sL "$url/users/$uid"`
			echo ok
			echo $data|jq -r .mastodon
			exit
			;;
		*)
			echo true,false
			exit
			;;
	esac
fi

if [ "atp" = "`echo $3|cut -d = -f 1`" ];then
	echo atproto mode
	b=`echo $3|cut -d = -f 2`
	case $b in
		true|false)
			data=`curl -X PATCH -H "Content-Type: application/json" -d "{\"token\":\"$token\",\"bsky\":$b}" -sL "$url/users/$uid"`
			echo ok
			echo $data|jq -r .bsky
			exit
			;;
		*)
			echo true,false
			exit
			;;
	esac
fi

if [ "admin" = "`echo $3|cut -d = -f 1`" ];then
	if [ "syui.ai" = "$1" ] || [ "ai" = "$1" ];then
		echo "
		{
			\"raid_admin\":\"`echo $3|cut -d = -f 2`\",
			\"raid_time\": null,
			\"raid_card\": 23
		}" | jq . >! $cfg
			cat $cfg
			echo please : /card raid-start
	else
		echo no admin
	fi
	exit
fi

if [ "room" = "`echo $3|cut -d = -f 1`" ];then
	room=`echo $3|cut -d = -f 2`
	data_uu=`curl -sL "$url/users/$uid/card?itemsPerPage=3000"`
	card_check=`echo $data_uu|jq -r ".[]|select(.card >= 1 and .card <= 14).card"|sort|uniq|wc -l`

	if [ $room -ge 123 ] && [ $room -le 123 ];then
		if [ $card_check -ne 14 ];then
			echo "card 1-14 key is required"
			exit
		fi
	fi

	if { [ $room -ge 123 ] && [ $room -le 123 ] && [ $card_check -eq 14 ] } || [ $room -eq 0 ] || { [ $room -ge 1 ] && [ $room -le 3 ] } || [ $room -eq 124 ]; then
		if [ $room -ge 123 ] && [ $room -le 123 ];then
			echo "welcome to secret room !"
		else
			echo "welcome to room"
		fi

		tmp=`curl -sL -X PATCH -H "Content-Type: application/json" -d "{\"room\": $room,\"token\":\"$token\"}" -s $url/users/$uid`

		if [ $room -ge 123 ] && [ $room -le 123 ];then
			card=65
			cp=0
			s=super
			card_check=`echo $data_uu|jq -r ".[]|select(.card == $card)"`
			if [ -n "$card_check" ];then
				echo "you already have"
			else
				tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$card,\"status\":\"$s\",\"cp\":$cp,\"password\":\"$pass\",\"skill\":\"$skill\"}" -s $url/cards`
			fi
		fi

		exit

	fi
fi

if [ "$3" = "-raid" ] || [ "$3" = "-r" ] || [ "$3" = "r" ];then
	battle_raid $1 $2
fi

if [ "$3" = "-server" ] || [ "$3" = "-s" ] || [ "$3" = "s" ] || [ "$3" = "server" ];then
	battle_server $1 $2
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
	cp=$(($RANDOM % 2000 + 500))
	yui_card 47 $cp 
	exit
fi

if [ "$3" = "chou" ] || [ "$3" = "-chou" ];then
	cp=$(($RANDOM % 1500 + 500))
	yui_card 60 $cp 
	exit
fi

if [ "$3" = "study" ] || [ "$3" = "-study" ];then
	cp=0
	if [ `echo $(($RANDOM % 2))` -eq 1 ];then
		study_card 61 $cp 
	else
		study_card 62 $cp 
	fi
	exit
fi

if [ "$3" = "-egg" ] || [ "$3" = "egg" ];then
	egg_card
	exit
fi

if [ "$3" = "moji" ] || [ "$3" = "-moji" ];then
	echo "not open"
	exit
	card=27
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

	s=super
	moji_mode_card $card $cp $skill $s

	exit
fi

if [ "$3" = "bingo" ] || [ "$3" = "-bingo" ];then
	card=35
	bingo=`curl -sL https://bingo.b35.jp/bonus.csv`
	bingo_data=`echo $bingo|grep $1|tail -n 1`
	bingo_d=`echo $bingo_data|cut -d , -f 1`
	bingo_w=`echo $bingo_data|cut -d , -f 2`

	if [ -z "$bingo_data" ] || [ -z "$bingo_d" ];then
		echo no bingo
		exit
	fi
	if [ $bingo_w -eq 2 ];then 
		s=super
	else
		s=normal
	fi
	if [ "$bingo_d" = "20230630" ] || [ "$bingo_d" = "20230629" ];then 
		cp=0
		skill=normal
		moji_mode_card $card $cp $skill $s
		exit
	else
		echo no bingo day
		exit
	fi
fi

if [ "$3" = "wa" ] || [ "$3" = "-wa" ];then
	echo "not open"
	exit
	plus=$(($RANDOM % 800 + 400))
	cp=$((cp + plus))

	skill=$(($RANDOM % 2))
	if [ $skill -eq 1 ];then
		skill=critical
		plus=$(($RANDOM % 500))
		cp=$((cp + plus))
	else
		skill=normal
	fi

	skill=$(($RANDOM % 10))
	if [ $skill -eq 1 ];then
		skill=post
		plus=$(($RANDOM % 500))
		cp=$((cp + plus))
	else
		skill=normal
	fi

	s=super
	moji_mode_card 28 $cp $skill $s

	exit
fi

if [ "$3" = "zen" ] || [ "$3" = "-zen" ];then
	yui_card 20 123
	exit
fi

if [ "$3" = "field" ] || [ "$3" = "-field" ];then
	field_card $(($RANDOM % 9 + 1))
	exit
fi

if [ "$3" = "g15" ] || [ "$3" = "-g15" ];then
	plus=$(($RANDOM % 1800 + 400))
	cp=$((cp + plus))
	st=super
	moji_mode_card 71 $cp $skill $st
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
		# 革命前
		tt=`echo $data_uu|jq ".[].cp"|sort -n -r`
		ttt=`echo $data_u|jq ".[].cp"|sort -n -r`
		# 革命後
		#tt=`echo $data_uu|jq ".[].cp"|sort -n`
		#ttt=`echo $data_u|jq ".[].cp"|sort -n`

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

		if [ -n "$fav_cid" ] && [ $fav_cid -ne 0 ];then
			fav_card=`echo $data_uu|jq -r ".[]|select(.id == $fav_cid)"`
			fav_card_id=`echo $fav_card|jq -r ".id"`
			fav_card_cp=`echo $fav_card|jq -r ".cp"`
			fav_card_name=`echo $fav_card|jq -r ".card"`
			fav_card_status=`echo $fav_card|jq -r ".status"`
			fav_card_skill=`echo $fav_card|jq -r ".skill"`
			fav_card_ran=$(($RANDOM % 4))
			if [ $fav_card_ran -eq 0 ];then
				cp_i=$fav_card_cp
			fi
		fi

		echo $tt | sed -n 1,3p
		if [ -n "$fav_cid" ] && [ $fav_cid -ne 0 ];then
			echo "$fav_card_cp ✧"
		fi
		echo "---"
		echo id : $r
		echo $ttt | sed -n 1,3p
		echo "---"
		echo $cp_i vs $cp_b

		if [ -n "$fav_card_id" ] && [ $fav_card_ran -eq 0 ];then
			$fav_com $username $did b $cp_b
			exit
		fi

		# 革命前
		if [ $cp_i -gt $cp_b ];then
		# 革命後
		#if [ $cp_b -gt $cp_i ];then
			echo "win!"
		else
			echo loss
		fi

		# 革命前
		if [ $cp_i -gt $cp_b ];then
		# 革命後
		#if [ $cp_b -gt $cp_i ];then
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
	if [ -z "$data" ];then
		exit
	fi

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
tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"next\":\"$nd\",\"token\":\"$token\",\"room\":0}" -s $url/users/$uid`

### new card
card=60
if [ $(($RANDOM % 5)) -eq 0 ];then
	cp=$(($RANDOM % 3000 + 200))
	yui_card_add $card $cp 
	exit
fi

card=67
if [ $(($RANDOM % 5)) -eq 0 ];then
	cp=$(($RANDOM % 3000 + 200))
	yui_card_add $card $cp 
	exit
fi

card=77
if [ $(($RANDOM % 15)) -eq 0 ];then
	cp=$(($RANDOM % 3000 + 200))
	yui_card_add $card $cp 
	exit
fi

card=78
if [ $(($RANDOM % 15)) -eq 0 ];then
	cp=$(($RANDOM % 3000 + 200))
	yui_card_add $card $cp 
	exit
fi

s=`echo $(($RANDOM % 3))`
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

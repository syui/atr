#!/bin/zsh

case $OSTYPE in
	darwin*)
		alias date="/opt/homebrew/bin/gdate"
		;;
esac

PATH=$PATH:$HOME/.cargo/bin
d=$HOME/.config/msr
f=$HOME/.config/msr/notify_log.txt
card=$HOME/.config/atr/scpt/api_card.zsh

if [ ! -d $d ];then
	mkdir -p $d
fi

j=`$HOME/.cargo/bin/msr bot`

tmp=`echo $j|jq length`
if [ $tmp -eq 0 ];then
	exit
fi

data_id=`echo $j|jq -r ".id"`
n=`echo $data_id|wc -l`
data_mid=`echo $j|jq -r ".mid"`
data_text=`echo $j|jq -r ".body"`
data_url=`echo $j|jq -r ".url"`
data_server=`echo $j|jq -r ".url"|cut -d / -f 3`
data_user=`echo $j|jq -r ".user"`

function user_create() {
	if [ -n "$ap" ] && [ -n "$url" ];then
		data=`curl -X POST -H "Content-Type: application/json" -d "{\"username\":\"$ap\",\"password\":\"$pass\",\"did\":\"$url\",\"next\":\"$nd_o\",\"updated_at\":\"$updated_at_o\"}" -sL "$host/users"`
		uid=`echo $data|jq -r ".id"`
		echo id $uid
	else
		echo error user create
	fi
}

function card_env() {
	card_url=https://card.syui.ai
	host=https://api.syui.ai
	d=`date +"%Y%m%d"`
	nd=`date +"%Y%m%d" -d '1 day'`
	nd_o=`date +"%Y%m%d" -d '-1 day'`
	updated_at_o=`date --iso-8601=seconds -d '-1 day'`
	username=`echo $1|cut -d . -f 1`
	url_user_all="$host/users?itemsPerPage=2000"
	pass=`cat $HOME/.config/atr/api_card.json|jq -r .password`
	token=`cat $HOME/.config/atr/api_card.json|jq -r .token`
	data_tmp=`curl -sL $url_user_all`
	data=`echo "$data_tmp"|jq ".[]|select(.username == \"$ap\")"`
	if [ -z "$data" ];then
		data=`echo "$data_tmp"|jq ".[]|select(.username == \"$username\")"`
	fi
	if [ -z "$data" ];then
		echo no $username
		user_create
	fi
	username=`echo $data|jq -r .username`
	data_did_check=`echo $data|jq -r .did`
	uid=`echo $data|jq -r ".id"`
	delete=`echo $data|jq -r ".delete"`
	mastodon=`echo $data|jq -r ".mastodon"`
	did=`echo $data|jq -r ".did"`
	handle_change=`echo $data|jq -r ".handle"`
	raid_at=`echo $data|jq -r .raid_at`
	raid_at=`date -d "$raid_at" +"%Y%m%d"`
	raid_at_n=`date --iso-8601=seconds`
	server_at=`echo $data|jq -r .server_at`
	server_at=`date -d "$server_at" +"%Y%m%d"`
	server_at_n=`date --iso-8601=seconds`

	updated_at=`echo $data|jq -r .updated_at`
	updated_at=`date -d "$updated_at" +"%Y%m%d"`
	updated_at_n=`date --iso-8601=seconds`
	next=`echo $data|jq -r .next`
	aiten=`echo $data|jq -r .aiten`
	ten_su=`echo $data|jq -r .ten_su`
	if [ "$a_team" = false ];then
		echo "bsky @${username}"
		echo "no activitypub-mode"
		return 0
	fi
	echo "$card_url/$username"
}

function card_day() {
	card_env $1
	if [ $next -gt $d ] || [ "$updated_at" = "$d" ];then
		echo limit 1 day
		return 0
	fi

	tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"password\":\"$pass\"}" -sL $host/cards`
	card=`echo $tmp|jq -r .card`
	card_url=`echo $tmp|jq -r .url`
	cp=`echo $tmp|jq -r .cp`
	skill=`echo $tmp|jq -r .skill`
	if [ -z "$card" ];then
		tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"password\":\"$pass\"}" -sL $host/cards`
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
	tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"next\":\"$nd\",\"token\":\"$token\"}" -sL $host/users/$uid`
}

function card_b() {
	card_env $1
	if [ $updated_at -ge $d ] || [ "$updated_at" = "$d" ];then
		echo "limit battle"
		return 0
	fi
	id_all=`curl -sL "$host/users?itemsPerPage=2000"|jq ".[]|.id"`
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

	data_uu=`curl -sL "$host/users/$uid/card?itemsPerPage=2000"`
	data_u=`curl -sL "$host/users/$r/card?itemsPerPage=2000"`

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
			return 0
		fi
		if [ -z "$cp_b" ];then
			echo "null error"
			return 0
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
			tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"password\":\"$pass\"}" -sL $host/cards`
			card=`echo $tmp|jq -r .card`
			card_url=`echo $tmp|jq -r .url`
			cp=`echo $tmp|jq -r .cp`
			if [ -z "$card" ];then
				tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"password\":\"$pass\"}" -sL $host/cards`
				card=`echo $tmp|jq -r .card`
				card_url=`echo $tmp|jq -r .url`
				cp=`echo $tmp|jq -r .cp`
			fi
			echo "[card]"
			echo id : $card
			echo cp : $cp
			t=`echo $tmp|jq -r .card`
		fi

		tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"updated_at\":\"$updated_at_n\",\"token\":\"$token\"}" -sL $host/users/$uid`
}

function card_s(){
	card_env $1
	username=$1
	a_team=mastodon
	b_team=bluesky
	rr=`date +"%H%M"`
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

	if [ $server_at -ge $d ] || [ "$server_at" = "$d" ];then
		echo "limit battle"
		exit
	fi

	data_uu=`curl -sL "$host/users/$uid/card?itemsPerPage=2000"`
	fav_card=`echo $data_uu|jq "sort_by(.cp)|reverse|.[0]"`

	if [ ! -f $f_server_user_at ];then
		echo start >> $f_server_user_at
	fi
	if [ ! -f $f_server_user_ap ];then
		echo start >> $f_server_user_ap
	fi
	commit_user_at=`cat $f_server_user_at|tail -n 1`
	commit_user_ap=`cat $f_server_user_ap|tail -n 1`
	echo $username >> $f_server_user_ap

	cp_i=`echo $fav_card|jq -r ".cp"`
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

	cp_all=$((cp_i + cp_ap))

 # サーバーバトルの還元期間
	#cp_all=$((cp_ap - cp_i))

	if [ "$skill" = "critical" ];then
		echo "⚡  $cp_i ---> $cp_ap"
	elif [ "$skill" = "post" ];then
		cp_post=`$HOME/.cargo/bin/atr pro $1 -p`
		cp_i=$((cp_i + cp_post))
		cp_all=$((cp_i + cp_ap))
		echo "🔥 $cp_i ---> $cp_ap"
	elif [ "$skill" = "luck" ];then
		echo "✨ $cp_i ---> $cp_ap"
	elif [ "$skill" = "dragon" ];then
		echo "🐉 $cp_i ---> $cp_ap"
	elif [ "$skill" = "yui" ];then
		echo "🔅 $cp_i ---> $cp_ap"
	else 
		echo "✧ $cp_i ---> $cp_ap"
	fi

	echo $cp_all >! $f_server_ap
	echo 
	echo "[${a_team}] ${cp_all}"
	echo "┣ @${username}"
	echo "┗ @${commit_user_ap}"
	echo
	echo "┏━ vs ━┛"
	echo
	echo "[${b_team}] ${cp_at}"
	echo "┗ @${commit_user_at}"
	#echo "[log]"
	#echo "${cp_ap}/$a_team --> ${commit_user_ap}"
	#echo "${commit_user_at} <-- ${cp_at}/$b_team"
	#echo "${username} --> $cp_all/$a_team"

	if [ $rr -gt $server_time ];then
		#echo "----"
		#echo "timeup!"
		echo 1 >! $f_server
		rm $f_server_start_time
		rm $f_server_at
		rm $f_server_ap
		mv $f_server_user_at $f_server_user_at.back
		mv $f_server_user_ap $f_server_user_ap.back
	fi

	echo "----"
	cp_plus=$(($RANDOM % 100 + 1))
	cp=$((cp_ii + cp_plus))
	body="level up!"
	echo "${body} ✧${cp}(+${cp_plus})"
	tmp=`curl -sL -X PATCH -H "Content-Type: application/json" -d "{\"cp\":$cp,\"token\":\"$token\"}" $host/cards/$fav`
	tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"server_at\":\"$server_at_n\", \"token\":\"$token\"}" -s $host/users/$uid`
}

function mastodon_notify() {
	for ((i=1;i<=$n;i++))
	do
		mid=`echo $data_mid|awk "NR==$i"`
		check=`cat $f|grep $mid`
		if [ -n "$check" ];then
			echo ok
			continue
		fi

		url=`echo $data_url|awk "NR==$i"`
		user=`echo $data_user|awk "NR==$i"`
		text=`echo $data_text|awk "NR==$i"`
		server=`echo $data_server|awk "NR==$i"`
		ap="@${user}@${server}"

		if [ -f "$GOPATH/bin/pup" ];then
			text=`echo ${text}|pup "p text{}"|tail -n 1|cut -d " " -f 2-|tr -d '"'|sed -e "s/&#39;/'/g" -e 's/&quot;/"/g'`
		else
			text=`echo ${text}|sed -e 's/<[^>]*>//g'|cut -d " " -f 2-|tr -d '"'|sed -e "s/&#39;/'/g" -e 's/&quot;/"/g'`
		fi

		echo $text
		com=`echo $text|cut -d " " -f 1`
		opt=`echo $text|cut -d " " -f 2`

		if [ "card" = "$com" ] || [ "/card" = "$com" ];then

			if [ "b" = "$opt" ] || [ "-b" = "$opt" ];then
				text=`card_b $user`
				echo $user $text
				msr cn "@${user}@${server} `echo $text`" -mm $mid
				echo $mid >> $f
				continue
			fi

			if [ "s" = "$opt" ] || [ "-s" = "$opt" ];then
				text=`card_s $user`
				echo $user $text
				msr cn "@${user}@${server} `echo $text`" -mm $mid
				echo $mid >> $f
				continue
			fi

			text=`card_day $user`
			echo $user $text
			msr cn "@${user}@${server} `echo $text`" -mm $mid
			echo $mid >> $f

		fi

	done
}

mastodon_notify

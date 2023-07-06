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

function card_env() {
	card_url=https://card.syui.ai
	host=https://api.syui.ai
	d=`date +"%Y%m%d"`
	nd=`date +"%Y%m%d" -d '1 day'`
	username=`echo $1|cut -d . -f 1`
	url_user_all="$host/users?itemsPerPage=2000"
	pass=`cat $HOME/.config/atr/api_card.json|jq -r .password`
	token=`cat $HOME/.config/atr/api_card.json|jq -r .token`
	data_tmp=`curl -sL $url_user_all`
	data=`echo "$data_tmp"|jq ".[]|select(.username == \"$username\")"`
	data_did_check=`echo $data|jq -r .did`
	uid=`echo $data|jq -r ".id"`
	delete=`echo $data|jq -r ".delete"`
	did=`echo $data|jq -r ".did"`
	handle_change=`echo $data|jq -r ".handle"`
	updated_at=`echo $data|jq -r .updated_at`
	updated_at=`date -d "$updated_at" +"%Y%m%d"`
	updated_at_n=`date --iso-8601=seconds`
	next=`echo $data|jq -r .next`
	if [ -z "$data" ];then
		echo no $username
		exit
	fi
	echo "$card_url/$username"
}

function card_day() {
	card_env $1
	if [ $next -gt $d ] || [ "$updated_at" = "$d" ];then
		echo limit 1 day
		exit
	fi

	tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"password\":\"$pass\"}" -s $host/cards`
	card=`echo $tmp|jq -r .card`
	card_url=`echo $tmp|jq -r .url`
	cp=`echo $tmp|jq -r .cp`
	skill=`echo $tmp|jq -r .skill`
	if [ -z "$card" ];then
		tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"password\":\"$pass\"}" -s $host/cards`
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
	tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"next\":\"$nd\",\"token\":\"$token\"}" -s $host/users/$uid`
}

function card_b() {
	card_env $1
	if [ $updated_at -ge $d ] || [ "$updated_at" = "$d" ];then
		echo "limit battle"
		exit
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
			tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"password\":\"$pass\"}" -s $host/cards`
			card=`echo $tmp|jq -r .card`
			card_url=`echo $tmp|jq -r .url`
			cp=`echo $tmp|jq -r .cp`
			if [ -z "$card" ];then
				tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"password\":\"$pass\"}" -s $host/cards`
				card=`echo $tmp|jq -r .card`
				card_url=`echo $tmp|jq -r .url`
				cp=`echo $tmp|jq -r .cp`
			fi
			echo "[card]"
			echo id : $card
			echo cp : $cp
			t=`echo $tmp|jq -r .card`
		fi

		tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"updated_at\":\"$updated_at_n\",\"token\":\"$token\"}" -s $host/users/$uid`
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

			text=`card_day $user`
			echo $user $text
			msr cn "@${user}@${server} `echo $text`" -mm $mid
			echo $mid >> $f

		fi

	done
}

mastodon_notify

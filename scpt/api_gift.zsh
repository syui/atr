#!/bin/zsh

case $OSTYPE in
	darwin*)
		alias date="/opt/homebrew/bin/gdate"
		;;
esac

atr=$HOME/.cargo/bin/atr
host=https://api.syui.ai

pass=`cat $HOME/.config/atr/api_card.json|jq -r .password`
token=`cat $HOME/.config/atr/api_card.json|jq -r .token`

handle=$1
did=$2
username=`echo $1|cut -d . -f 1`
cid=`echo $3|cut -d ' ' -f 1`
guser=$4

if [ "$3" = "ai" ];then
	guser=ai
fi

if [ -z "$cid" ];then
	echo no option
	echo "---"
	echo "@yui.syui.ai /gift ai"
	echo "---"
	echo "@yui.syui.ai /gift status"
	echo "12345"
	echo "67891"
	echo "---"
	echo "@yui.syui.ai /gift 12345"
	echo ""
	echo "---"
	echo "@yui.syui.ai /gift 12345 syui"
	exit
fi

function card_env(){
	all_data=`curl -sL "$host/users?itemsPerPage=3000"`
	data=`echo $all_data|jq ".[]|select(.username == \"$username\")"`
	gdata=`echo $all_data|jq ".[]|select(.username == \"$guser\")"`
	if [ -z "$data" ];then
		exit
	fi

	uid=`echo $data|jq -r .id`
	gid=`echo $gdata|jq -r .id`

	aiten=`echo $data|jq -r .aiten`
	fav=`echo $data|jq -r .fav`

	cdata=`curl -sL $host/cards/$cid`
	if [ -z "$cdata" ];then
		echo no card
		exit
	fi

	card=`echo $cdata|jq -r .card`
	cp=`echo $cdata|jq -r .cp`
	count=`echo $cdata|jq -r .count`
	author=`echo $cdata|jq -r .author`
	skill=`echo $cdata|jq -r .skill`
	s=`echo $cdata|jq -r .status`

	if [ $count -eq 0 ];then
		echo card count 0
		exit
	fi

	if [ $author != "$username" ];then
		echo no author
		echo "$author --> $username"
		exit
	fi
}

function card_env_ai(){
	guser=ai
	all_data=`curl -sL "$host/users?itemsPerPage=3000"`
	data=`echo $all_data|jq ".[]|select(.username == \"$username\")"`
	gdata=`echo $all_data|jq ".[]|select(.username == \"$guser\")"`
	if [ -z "$data" ];then
		exit
	fi

	uid=`echo $data|jq -r .id`
	gid=`echo $gdata|jq -r .id`

	aiten=`echo $data|jq -r .aiten`
	fav=`echo $data|jq -r .fav`

	cdata=`curl -sL "$host/users/$uid/card?itemsPerPage=3000"|jq ".[0]"`
	if [ -z "$cdata" ];then
		cdata=`curl -sL "$host/users/$uid/card?itemsPerPage=3000"|jq ".[]|select(.author == \"$username\")"|jq -s ".[0]"`
	fi

	if [ -z "$cdata" ];then
		echo no card
		exit
	fi

	cid=`echo $cdata|jq -r .id`
	card=`echo $cdata|jq -r .card`
	cp=`echo $cdata|jq -r .cp`
	count=`echo $cdata|jq -r .count`
	author=`echo $cdata|jq -r .author`
	skill=`echo $cdata|jq -r .skill`
	s=`echo $cdata|jq -r .status`

	if [ $count -eq 0 ];then
		echo card count 0
		exit
	fi

	if [ $author != "$username" ];then
		echo no author
		echo "$author --> $username"
		exit
	fi

	aicard=`curl -sL "$host/users/$gid/card?itemsPerPage=3000"|jq -r ".[]|select(.card >= 1)"|jq -s`
	if [ -z "$aicard" ];then
		exit
	fi
	n=`echo $aicard|jq length`
	n=$((n - 1))
	ran=$((RANDOM % n))
	ai_id=`echo $aicard|jq -r ".[$ran]|.id"`
	ai_card=`echo $aicard|jq -r ".[$ran]|.card"`
	ai_cp=`echo $aicard|jq -r ".[$ran]|.cp"`
	ai_skill=`echo $aicard|jq -r ".[$ran]|.skill"`
	ai_s=`echo $aicard|jq -r ".[$ran]|.status"`
	ai_author=ai
}

function card_env_ai_select(){
	all_data=`curl -sL "$host/users?itemsPerPage=3000"`
	data=`echo $all_data|jq ".[]|select(.username == \"$username\")"`
	gdata=`echo $all_data|jq ".[]|select(.username == \"$guser\")"`
	if [ -z "$data" ];then
		exit
	fi

	uid=`echo $data|jq -r .id`
	gid=`echo $gdata|jq -r .id`

	aiten=`echo $data|jq -r .aiten`
	fav=`echo $data|jq -r .fav`

	cdata=`curl -sL $host/cards/$cid`
	if [ -z "$cdata" ];then
		echo no card
		exit
	fi

	cid=`echo $cdata|jq -r .id`
	card=`echo $cdata|jq -r .card`
	cp=`echo $cdata|jq -r .cp`
	count=`echo $cdata|jq -r .count`
	author=`echo $cdata|jq -r .author`
	skill=`echo $cdata|jq -r .skill`
	s=`echo $cdata|jq -r .status`

	if [ $count -eq 0 ];then
		echo card count 0
		exit
	fi

	if [ $author != "$username" ];then
		echo no author
		echo "$author --> $username"
		exit
	fi

	aicard=`curl -sL "$host/users/$gid/card?itemsPerPage=3000"|jq -r ".[]|select(.card >= 1)"|jq -s`
	if [ -z "$aicard" ];then
		exit
	fi
	n=`echo $aicard|jq length`
	n=$((n - 1))
	ran=$((RANDOM % n))
	ai_id=`echo $aicard|jq -r ".[$ran]|.id"`
	ai_card=`echo $aicard|jq -r ".[$ran]|.card"`
	ai_cp=`echo $aicard|jq -r ".[$ran]|.cp"`
	ai_skill=`echo $aicard|jq -r ".[$ran]|.skill"`
	ai_s=`echo $aicard|jq -r ".[$ran]|.status"`
	ai_author=ai
}

function card_gift() {
	card_env
	if [ -z "$guser" ];then
		echo card:$card
		echo skill:$skill
		echo status:$s
		echo count:$count
		echo author:$author
		exit
	fi
	count=$((count - 1))
	tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$gid,\"card\":$card,\"status\":\"$s\",\"cp\":$cp,\"password\":\"$pass\",\"skill\":\"$skill\",\"author\":\"$username\",\"count\":0}" -sL $host/cards`
	tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"count\":$count,\"token\":\"$token\"}" $host/cards/$cid -sL`
	echo ok
	echo "$author($cid) -->  $guser"
}

function card_ai() {
	card_env_ai
	count=$((count - 1))
	tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$gid,\"card\":$card,\"status\":\"$s\",\"cp\":$cp,\"password\":\"$pass\",\"skill\":\"$skill\",\"author\":\"$username\",\"count\":0}" -sL $host/cards`
	tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"count\":$count,\"token\":\"$token\"}" $host/cards/$cid -sL`
	echo ok
	echo "$author($cid) -->  $guser"
	echo "---"
	echo 'thx!'
	echo card:$ai_card
	echo cp:$ai_cp
	echo author:$ai_author
	tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$ai_card,\"status\":\"$ai_s\",\"cp\":$ai_cp,\"password\":\"$pass\",\"skill\":\"$ai_skill\",\"author\":\"$ai_author\",\"count\":0}" -sL $host/cards`
}

function card_ai_select() {
	card_env_ai_select
	count=$((count - 1))
	tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$gid,\"card\":$card,\"status\":\"$s\",\"cp\":$cp,\"password\":\"$pass\",\"skill\":\"$skill\",\"author\":\"$username\",\"count\":0}" -sL $host/cards`
	tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"count\":$count,\"token\":\"$token\"}" $host/cards/$cid -sL`
	echo ok
	echo "$author($cid) -->  $guser"
	echo "---"
	echo 'thx!'
	echo card:$ai_card
	echo cp:$ai_cp
	echo author:$ai_author
	tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$ai_card,\"status\":\"$ai_s\",\"cp\":$ai_cp,\"password\":\"$pass\",\"skill\":\"$ai_skill\",\"author\":\"$ai_author\",\"count\":0}" -sL $host/cards`
}

function card_status(){
	all_data=`curl -sL "$host/users?itemsPerPage=3000"`
	data=`echo $all_data|jq ".[]|select(.username == \"$username\")"`
	uid=`echo $data|jq -r .id`
	acard=`curl -sL "$host/users/$uid/card?itemsPerPage=3000"|jq ".[]|select(.author == \"$username\")|.id"`
	if [ -z "$acard" ];then
		echo no card
		exit
	fi
	echo $acard
}

function test_cmd(){
	echo "test ok /gift $1"
	echo cid:$cid
	echo guser:$guser
	exit
}

case $cid in
	"status")
		card_status
		;;
	"ai")
		#test_cmd ai
		card_ai
		;;
	*)
		if [ "ai" = "$guser" ];then
			#test_cmd ai_select
			card_ai_select
		else
			#test_cmd gift user
			card_gift
		fi
		;;
esac

exit

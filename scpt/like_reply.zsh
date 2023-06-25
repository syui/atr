#!/bin/zsh

atr=$HOME/.cargo/bin/atr
host=api.syui.ai
data=`curl -sL "$host/users?itemsPerPage=3000"|jq ".|sort_by(.like)|reverse|.[]|select(.like_rank > 1)"`
tmp=`echo $data|jq -s`
n=`echo $tmp|jq "length"`
ran=$(($RANDOM % n - 1))
echo $ran

function did() {
		user=`echo $tmp|jq -r ".[$ran].username"`
		did=`echo $tmp|jq -r ".[$ran].did"`
}

function tl(){
	did
	cid=`$atr f $did|jq  -r ".records|.[0].cid"`
	uri=`$atr f $did|jq  -r ".records|.[0].uri"`
	text=`$atr f $did|jq -r ".records|.[0].value.text"`
	echo $cid
	echo $uri
	echo $text
	find=`echo $text|grep "card.syui.ai"`
	find_t=`echo $text|grep "ten : "`
	if [ -n "$find" ] || [ -n "$find_t" ];then
		exit
	fi
	text=`$atr chat "$text" -c`
	echo $text
}

function reply(){
	tl
	if [ -n "$text" ] && [ -n "$uri" ];then
		$atr r "$text" -u $uri -c $cid
	fi
}

reply

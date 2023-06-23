#!/bin/zsh

atr=$HOME/.cargo/bin/atr
host=api.syui.ai
data=`curl -sL "$host/users?itemsPerPage=3000"|jq ".|sort_by(.like)|reverse|.[]|select(.like_rank > 1)"`
tmp=`echo $data|jq -s`
n=`echo $tmp|jq "length"`
ran=$(($RANDOM % n - 1))

function did() {
	for ((i=0;i<$n;i++))
	do
		user=`echo $tmp|jq -r ".[$i].username"`
		did=`echo $tmp|jq -r ".[$i].did"`
		if [ $ran -eq $i ];then
			echo $did
		fi
	done
}

function tl(){
	did=`did`
	cid=`$atr f $did|jq  -r ".[]|.[0]?|.post.cid"`
	uri=`$atr f $did|jq  -r ".[]|.[0]?|.post.uri"`
	text=`$atr f $did|jq  -r ".[]|.[0]?|.post.record.text"`
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

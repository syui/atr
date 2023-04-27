#!/bin/zsh

d=$HOME/.config/atr/txt
mkdir -p $d
unset cursor

function page(){
	s=$1
	if [ "$s" = "ers" ];then
		opt="-w"
	elif [ "$s" = "s" ];then
		opt="-s"
	fi

	f=$d/follow${s}_${ii}.json
	echo $f
	if [ -n "$cursor" ];then
		if [ ! -f $f ];then 
			atr follow $opt -c $cursor| jq . >! $f
		else
			echo no download
		fi
	else
		if [ ! -f $f ];then 
			atr follow $opt| jq . >! $f
		else
			echo no download
		fi
	fi
	cursor=`cat $f|jq -r .cursor`

	echo "------------------------------"
	echo $cursor
	echo "------------------------------"
	n=`cat $f|jq ".follow${s}|length"`
	n=`expr $n - 1`

	for ((i=0;i<=$n;i++))
	do
		handle=`cat $f|jq -r ".follow${s}|.[$i].handle"`
		did=`cat $f|jq -r ".follow${s}|.[$i].did"`
		flg=`cat $f|jq -r ".follow${s}|.[$i].viewer.following"`
		flb=`cat $f|jq -r ".follow${s}|.[$i].viewer.followedBy"`
		if [ "$flg" = "null" ];then 
			echo following
			echo $flb
			echo "follow : $handle"
			echo "atr follow $did"
			atr follow $did
		fi
		if [ "$flb" = "null" ];then 
			rkey=${flg##*/}
			echo followedBy
			echo $flg
			echo "unfollow : $handle"
			echo "atr follow $did -d $rkey"
			atr follow $did -d $rkey
		fi
	done
}

ii=1
while [ "$cursor" != "null" ] 
do
	page ers $ii
	ii=`expr $ii + 1`
done

unset cursor
ii=1
while [ "$cursor" != "null" ] 
do
	page s $ii
	ii=`expr $ii + 1`
done

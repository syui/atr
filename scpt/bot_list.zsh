#!/bin/zsh

url_plc="https://plc.directory/export"
host_at=bsky.social
url=https://plc.directory
url_at=https://$host_at/xrpc/com.atproto.repo.listRecords
dir=$HOME/.config/atr/txt
file=$dir/bot_list.txt
unset timed

case $OSTYPE in
	darwin*)
		alias date="/opt/homebrew/bin/gdate"
		;;
esac

if [ -z "$1" ];then
	exit
fi

if ! echo $1|grep "." >/dev/null 2>&1;then
	echo "ex : user syui.bsky.social"
	exit
fi

if [ ! -d $dir ];then
	mkdir -p $dir
fi

if [ ! -f $file ];then
	touch $file
fi

function mfile() {
	t=`cat $file|sort|uniq`
	if [ -n "$t" ];then
		echo "$t" >! ${file}.back
		mv ${file}.back $file
	fi
}

function plc(){
	if cat $file|grep "$1" >/dev/null 2>&1;then
		cat $file|grep "$1"
		exit
	fi
	json_tmp=`curl -sL "${url_plc}?after=${timed}"|jq .`
	json=`echo $json_tmp|jq "select(.operation.handle == \"$1\")"`
	if [ -z "$json" ];then
		check=`echo $json_tmp|jq -r ".operation.alsoKnownAs"|head -n 1`
		if [ "null" != "$check" ];then
			json=`echo $json_tmp|jq "select(.operation.alsoKnownAs|.[] == \"at://$1\")"` >/dev/null 2>&1
		fi
	fi
	if [ -n "$json" ];then
		created_at=`echo $json|jq -r .createdAt |tail -n 1`
	fi
	if [ -n "$created_at" ];then
		echo "$created_at : $1"
		echo "$created_at : $1" >> $file
		mfile
		exit
	fi
}

if [ "$1" = "-l" ];then
	mfile
	cat $file
	exit
fi

for ((i=0;i<=20;i++))
do
	if [ $i -eq 0 ];then
		timed="1970-01-01"
	fi
	plc $1
	timed=`echo $json_tmp|jq -r .createdAt|tail -n 1`
done

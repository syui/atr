#!/bin/zsh

url_plc="https://plc.directory/export"
host_at=bsky.social
url=https://plc.directory
url_at=https://$host_at/xrpc/com.atproto.repo.listRecords
dir=$HOME/.config/atr/txt
file=$dir/user_list.txt


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

function fan_art(){
	if ! echo $3|grep "https://bsky.app/profile/">/dev/null 2>&1;then
		echo "please url : https://bsky.app/profile/$1/post/xxx"
		exit
	fi

	if [ -z "$4" ];then
		echo "please img-url : https://example.com/img.png"
		exit
	fi

	img=$4
	author=`echo $3|cut -d / -f 5`
	cd $dir_git_card_page
	cat $file_fanart|jq ".+ {\"add\":\"$1\",\"link\":\"$3\",\"author\":\"$author\",\"img\":\"$img\"}" >! $file_fanart.back
	if cat $file_fanart|jq . ;then
		mv $file_fanart.back $file_fanart
		git add $file_fanart
		git commit -m  "add fanart"
		git push -u orgin main
	fi
}

if [ "$2" = "--url" ];then
	if [ -z "$3" ];then
		exit
	fi
	fan_art $3
	exit
fi

function first(){
	#https://bsky.app/profile/$1/post/$e
	curl -sL "https://bsky.social/xrpc/com.atproto.repo.listRecords?repo=$1&collection=app.bsky.feed.post&reverse=true" |jq -r ".[]|.[0]?|.uri,.value"
}

if [ "$2" = "-f" ];then
	first $1
	exit
fi

if [ "$2" = "-l" ];then
	mfile
	cat $file
	exit
fi

function first_created(){
	#https://bsky.app/profile/$1/post/$e
	#curl -sL "https://bsky.social/xrpc/com.atproto.repo.listRecords?repo=$1&collection=app.bsky.feed.post&reverse=true" |jq -r ".[]|.[0]?|.createdAt"
	curl -sL "https://bsky.social/xrpc/com.atproto.repo.listRecords?repo=$1&collection=app.bsky.feed.post&reverse=true" |jq -r ".[]|.[0]?|.value.createdAt"
}

first_created $1


#for ((i=0;i<=300;i++))
#do
#	if [ $i -eq 0 ];then
#		timed="1970-01-01"
#	fi
#	plc $1
#	timed=`echo $json_tmp|jq -r .createdAt|tail -n 1`
#done

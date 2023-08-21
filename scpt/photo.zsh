#!/bin/zsh

url_plc="https://plc.directory/export"
host_at=bsky.social
url=https://plc.directory
url_at=https://$host_at/xrpc/com.atproto.repo.listRecords
dir=$HOME/.config/atr/txt
file=$dir/user_list.txt

dir_git_card_page=$HOME/git/card.syui.ai

if [ ! -d $dir_git_card_page ];then
	mkdir -p $HOME/git
	cd $HOME/git
	git clone https://github.com/syui/card.syui.ai
else
	cd $dir_git_card_page
	t=`git pull`
fi

file_photo=$dir_git_card_page/public/json/photo.json
case $OSTYPE in
	darwin*)
		alias date="/opt/homebrew/bin/gdate"
		;;
esac
created_at=`date --iso-8601=seconds`

#if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ];then
#	exit
#fi

function fan_art_search() {
	k="aiphoto"
	url="search.bsky.social/search/posts?q="
	t=`curl -sL "${url}${k}"|jq ".[]|select(.post.text == \"$k\")"`
	#n=`curl -sL "${url}${k}"|jq length`
	n=$((n - 1))
	for ((i=0;i<=$n;i++))
	do
		did=`curl -sL "${url}${k}"|jq -r ".[$i]|.user.did"`
		handle=`curl -sL https://plc.directory/$did|jq -r ".alsoKnownAs|.[]"|cut -d / -f 3-`
		if [ -z "$handle" ];then
			continue
		fi
		tid=`curl -sL "${url}${k}"|jq -r ".[$i]|.tid"|cut -d / -f 2`
		http=https://staging.bsky.app/profile/$handle/post/$tid
		echo $http
	done
}

if [ "$1" = "-s" ];then
	fan_art_search
	exit
fi

if ! echo $1|grep "." >/dev/null 2>&1;then
	echo "ex : user syui.bsky.social"
	exit
fi

if ! echo $2|grep "did:plc:" >/dev/null 2>&1;then
	echo "ex : user did"
	exit
fi

if [ "$3" = "-l" ];then
	curl -sL card.syui.ai/json/photo.json|jq -r ".[]|.author, .link"
	exit
fi

if ! echo $3|grep "bsky.app/profile/">/dev/null 2>&1;then
	echo "please url : bsky.app/profile/$1/post/xxx"
	exit
fi

if ! echo $4|grep "av-cdn.bsky.app/img/">/dev/null 2>&1;then
	echo "please url : av-cdn.bsky.app/img"
	exit
fi

function fan_art(){
	add=$1
	did=$2
	link=$3
	img=`echo $4|tr -d "'"`
	author=`echo $3|cut -d / -f 5`
	cd $dir_git_card_page
	check_null=`cat $file_photo|jq ".[]|select(.img == \"$img\")"`
	if [ -n "$check_null" ];then
		echo registered
		exit
	fi
	echo `cat $file_photo` "[{\"add\":\"$add\",\"link\":\"$link\",\"author\":\"$author\",\"img\":\"$img\",\"created_at\":\"$created_at\",\"did\":\"$did\"}]" | jq -s add >! $file_photo.back
	if cat $file_photo.back|jq . >/dev/null 2>&1;then
		mv $file_photo.back $file_photo
		git add $file_photo
		git commit -m  "add photo"
		git push -u origin main -f
		echo add photo, thx $1
		echo "author : $author"
		echo "it will take some time to deploy"
	fi
}

fan_art $1 $2 $3 $4
exit

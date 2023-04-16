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
	git pull
fi

file_fanart=$dir_git_card_page/public/json/fanart.json

created_at=`date --iso-8601=seconds`

case $OSTYPE in
	darwin*)
		alias date="/opt/homebrew/bin/gdate"
		;;
esac

#if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ];then
#	exit
#fi

if ! echo $1|grep "." >/dev/null 2>&1;then
	echo "ex : user syui.bsky.social"
	exit
fi

if [ "$2" = "-l" ];then
	curl -sL card.syui.ai/json/fanart.json|jq -r ".[]|.author, .link"
	exit
fi

if ! echo $2|grep "bsky.app/profile/">/dev/null 2>&1;then
	echo "please url : bsky.app/profile/$1/post/xxx"
	exit
fi

if ! echo $3|grep "https://cdn.bsky.social/imgproxy/">/dev/null 2>&1;then
	echo "please url : cdn.bsky.social/imgproxy"
	exit
fi

function fan_art(){
	img=`echo $3|tr -d "'"`
	author=`echo $2|cut -d / -f 5`
	cd $dir_git_card_page
	echo `cat $file_fanart` "[{\"add\":\"$1\",\"link\":\"$2\",\"author\":\"$author\",\"img\":\"$img\",\"created_at\":\"$created_at\"}]" | jq -s add >! $file_fanart.back
	if cat $file_fanart.back|jq . >/dev/null 2>&1;then
		mv $file_fanart.back $file_fanart
		git add $file_fanart
		git commit -m  "add fanart"
		git push -u origin main -f
		echo add fanart, thx $1
		echo "author : $author"
		echo "it will take some time to deploy"
	fi
}

fan_art $1 $2 $3 $4
exit

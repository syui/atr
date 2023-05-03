#!/bin/zsh
#
case $OSTYPE in
	darwin*)
		alias date="/opt/homebrew/bin/gdate"
		;;
esac

if [ "$1" = "test" ] || [ -z "$1" ];then
	handle=syui.ai
else
	handle=$1
fi

post=0
d=`date +"%Y-%m-%d"`
od=`date +"%Y-%m-%d" --date '1 day ago'`

unset cursor
function first_record(){
	cursor=`curl -sL "https://bsky.social/xrpc/com.atproto.repo.listRecords?repo=$handle&collection=app.bsky.feed.post&limit=100" |jq -r ".cursor"`
	t=`curl -sL "https://bsky.social/xrpc/com.atproto.repo.listRecords?repo=$handle&collection=app.bsky.feed.post&limit=100" |jq -r ".[]|.[]?|.value.createdAt"|cut -d T -f 1`
	n=`echo $t|wc -l`
}
function cursor_record(){
	cursor=`curl -sL "https://bsky.social/xrpc/com.atproto.repo.listRecords?repo=$handle&collection=app.bsky.feed.post&limit=100&cursor=$cursor" |jq -r ".cursor"`
	t=`curl -sL "https://bsky.social/xrpc/com.atproto.repo.listRecords?repo=$handle&collection=app.bsky.feed.post&limit=100&cursor=$cursor" |jq -r ".[]|.[]?|.value.createdAt"|cut -d T -f 1`
	n=`echo $t|wc -l`
}

function day_check(){
	for ((i=1;i<=$n;i++))
	do
		tt=`echo $t|awk "NR==$i"`
		if [ "$tt" = "$d" ];then
			post=$((post + 1))
			echo $post
		fi
		if [ "$tt" = "$od" ];then
			echo $tt $od
			echo $post
			exit
		fi
	done
}

for ((ii=1;ii<=100;ii++))
do
	if [ $ii -eq 1 ];then
		first_record
	else
		echo $cursor
		cursor_record
	fi
	day_check
done

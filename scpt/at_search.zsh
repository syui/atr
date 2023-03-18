#!/bin/zsh

url="search.bsky.social/search/posts?q="
q=`echo $*|tr ' ' '+'`
url="${url}${q}"

t=`curl -sL "$url"|jq .`
n=`echo $t|jq "length"`
n=`expr $n - 1`
for ((i=0;i<=$n;i++))
do
	did=`echo $t|jq -r ".[$i].user.did"`
	text=`echo $t|jq -r ".[$i].post.text"`
	tid=`echo $t|jq -r ".[$i].tid"`
	if [ "$text" != "null" ];then
		echo $did
		echo $text
		echo https://$tid
	fi
done

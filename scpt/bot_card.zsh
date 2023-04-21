#!/bin/zsh

host_at=bsky.social
url_at=https://$host_at/xrpc/com.atproto.repo.listRecords
scpt=$HOME/.config/atr/scpt/api_card.zsh 

handle=skychan.social
did=did:plc:7hgow77uky7lgbinwyvbzhar
f=$HOME/.config/atr/card_bot.txt
touch $f

n=0
for ((i=0;i<=$n;i++))
do
	echo $i
	cid=`curl -sL "https://bsky.social/xrpc/com.atproto.repo.listRecords?repo=$handle&collection=app.bsky.feed.post" |jq -r ".[]|.[$i]?|.cid"`
	if [ "$cid" = "`cat $f`" ];then
		exit
	fi
	echo $cid >! $f
	uri=`curl -sL "https://bsky.social/xrpc/com.atproto.repo.listRecords?repo=$handle&collection=app.bsky.feed.post" |jq -r ".[]|.[$i]?|.uri"`
	t=`curl -sL "https://bsky.social/xrpc/com.atproto.repo.listRecords?repo=$handle&collection=app.bsky.feed.post" |jq -r ".[]|.[$i]?|.value.text"`
	echo $t $cid $uri
	if [ "@yui.bsky.social /card" = "$t" ];then
		card=`$scpt $handle $did`
		link="https://card.syui.ai/skychan"
		~/.cargo/bin/atr r "$card" -c $cid -u "$uri" -l "$link"
	fi
	if [ "@yui.bsky.social /card -b" = "$t" ];then
		card=`$scpt $handle $did -b`
		link="https://card.syui.ai/skychan"
		~/.cargo/bin/atr r "$card" -c $cid -u "$uri" -l "$link"
	fi
done
exit

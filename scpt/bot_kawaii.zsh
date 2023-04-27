#!/bin/zsh

d=$HOME/.config/atr/txt
mkdir -p $d
f=$d/kawaii.txt

function test_post() {
	host_at=bsky.social
	url_at=https://$host_at/xrpc/com.atproto.repo.listRecords
	handle=lilly-niyu.bsky.social
	n=10
	for ((i=0;i<=$n;i++))
	do
		echo $i
		cid=`curl -sL "https://bsky.social/xrpc/com.atproto.repo.listRecords?repo=$handle&collection=app.bsky.feed.post" |jq -r ".[]|.[$i]?|.cid"`
		uri=`curl -sL "https://bsky.social/xrpc/com.atproto.repo.listRecords?repo=$handle&collection=app.bsky.feed.post" |jq -r ".[]|.[$i]?|.uri"`
		t=`curl -sL "https://bsky.social/xrpc/com.atproto.repo.listRecords?repo=$handle&collection=app.bsky.feed.post" |jq -r ".[]|.[$i]?|.value.text"`
		echo $t $cid $uri
		if [ "かわいいにゃ〜！！" = "$t" ];then
			#atr r "楽しそう！アイもまぜてよ" -c $cid -u "$uri"
		fi
	done
}

#uri=at://$did/$tid
#{
#  "tid": "app.bsky.feed.post/3judrtmxuin2b",
#  "cid": "bafyreibebbn7og5dgvvegcjlh357pnrpuvvinbjeaqbfvqb4jsrpbsw3di",
#  "user": {
#    "did": "did:plc:hodycxjeqfxtest2ilj47j7g",
#    "handle": "lilly-niyu.bsky.social"
#  },
#  "post": {
#    "createdAt": 1682587582509000000,
#    "text": "かわいいにゃ〜！！",
#    "user": "lilly-niyu.bsky.social"
#  }
#}

url="search.bsky.social/search/posts?q=かわいいにゃ〜！！"
q=`echo $*|tr ' ' '+'`
url="${url}${q}"

t=`curl -sL "$url"`
cid=`echo $t|jq -r ".[1].cid"`
did=`echo $t|jq -r ".[1].did"`
tid=`echo $t|jq -r ".[1].tid"`
uri="at://$did/$tid"
text=`echo $t|jq -r ".[1].post.text"`

touch $f

echo $text
if [ "かわいいにゃ〜！！" = "$text" ] && [ "`cat $f`" != "$cid" ];then
	echo ok
	atr r "楽しそう！アイもまぜてよ" -c $cid -u "$uri"
	echo $cid >! $f
else
	echo no
fi

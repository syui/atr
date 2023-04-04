#!/bin/zsh
d=${0:a:h}
dd=${0:a:h:h}/json
#https://github.com/bluesky-social/atproto/issues/597
host=bsky.social
base=https://$host/xrpc
handle=`cat ~/.config/atr/token.json| jq -r .handle`
token=`cat ~/.config/atr/token.json| jq -r .accessJwt`
if [ -n "$1" ];then
	url=$base/$1
else
	url="$base/app.bsky.actor.getProfile?actor=$handle"
fi

curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $token" $url | jq . >! $dd/profile.json

url=$base/app.bsky.feed.getTimeline
curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $token" $url | jq . >! $dd/timeline.json

url=$base/app.bsky.notification.listNotifications
curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $token" $url | jq . >! $dd/notify.json
cat $dd/notify.json|jq .

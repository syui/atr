#!/bin/zsh
d=${0:a:h}
dd=${0:a:h:h}/json
#https://github.com/bluesky-social/atproto/issues/597
host=`cat ~/.config/atr/config.json|jq -r .host`
base=https://$host/xrpc
handle=`cat ~/.config/atr/config.json|jq -r .user`
pass=`cat ~/.config/atr/config.json|jq -r .pass`
f=~/.config/atr/token.json

curl -X POST -H "Content-Type: application/json" -d "{\"handle\":\"$handle\",\"password\":\"$pass\"}" https://$host/xrpc/com.atproto.server.createSession | jq . >! $f
cat $f

if [ "$1" = "-a" ];then
	handle=`cat $f| jq -r .handle`
	token=`cat $f| jq -r .accessJwt`

	url="$base/app.bsky.actor.getProfile?actor=$handle"
	curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $token" $url | jq . >! $dd/profile.json
	cat $dd/profile.json

	url=$base/app.bsky.feed.getTimeline
	curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $token" $url | jq . >! $dd/timeline.json
	cat $dd/timeline.json

	url=$base/app.bsky.notification.listNotifications
	curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $token" $url | jq . >! $dd/notify.json
	cat $dd/notify.json|jq .
fi

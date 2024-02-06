#!/bin/zsh

admin_password=`cat $HOME/.config/atr/api_card.json|jq -r .pds_admin_password`
if [ -n "$1" ];then
	host=$1
else
	host=syu.is
fi
url=https://$host/xrpc/com.atproto.server.createInviteCode
json="{\"useCount\":30}"
echo $url
echo $admin_password
#curl -X POST -u admin:${admin_password} -H "Content-Type: application/json" -d "$json" -sL $url | jq -r .code
curl -X POST -u admin:${admin_password} -H "Content-Type: application/json" -d "$json" -sL $url

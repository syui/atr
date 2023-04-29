#!/bin/zsh

admin_password=`cat $HOME/.config/atr/api_card.json|jq -r .pds_admin_password`
host=bsky.syui.ai
url=https://$host/xrpc/com.atproto.server.createInviteCode
json="{\"useCount\":33}"
curl -X POST -u admin:${admin_password} -H "Content-Type: application/json" -d "$json" -sL $url | jq -r .code

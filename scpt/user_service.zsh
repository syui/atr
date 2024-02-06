#!/bin/zsh

if [ -n "$1" ];then
	did=$1
else 
	did=`atr did yui.syui.ai`
fi

pds=`curl -sL https://plc.directory/$did|jq -r ".service.[].serviceEndpoint" | cut -d / -f 3-`
handle=`curl -sL https://plc.directory/$did|jq -r ".alsoKnownAs.[]"|cut -d / -f 3-`

old_pds=`curl -sL https://plc.directory/$did/log|jq -r ".[0].service"|cut -d / -f 3-`
old_handle=`curl -sL https://plc.directory/$did/log|jq -r ".[0]|.handle"`

first_post=`curl -sL "https://bsky.social/xrpc/com.atproto.repo.listRecords?repo=$did&collection=app.bsky.feed.post&reverse=true" |jq -r ".[]|.[0]?|.value.createdAt"`

body_handle=$handle
body_pds=$pds

if [ "$old_handle" != "null" ];then
	body_handle="$old_handle -> $handle"
fi

if [ "$old_pds" != "null" ];then
	body_pds="$old_pds -> $pds"
fi

old_pds=`curl -sL https://plc.directory/$did/log|jq -r ".[0]|.services.atproto_pds.endpoint"|cut -d / -f 3-`
old_handle=`curl -sL https://plc.directory/$did/log|jq -r ".[0]|.alsoKnownAs.[0]"|cut -d / -f 3-`

if [ "$old_handle" != "null" ];then
	body_handle="$old_handle -> $handle"
fi

if [ "$old_pds" != "null" ];then
	body_pds="$old_pds -> $pds"
fi


if [ "$old_pds" = "$pds" ];then
	body_pds=$pds
fi

if [ "$old_handle" = "$handle" ];then
	body_handle=$handle
fi

echo pds : $body_pds
echo handle : $body_handle
echo did : $did
echo createdAt : $first_post

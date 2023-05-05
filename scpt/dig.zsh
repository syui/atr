#!/bin/zsh

txt=_atproto.$1
did=$2
curl -sL plc.directory/$did/log |jq ".[]|.alsoKnownAs|.[]?" | grep -n .| head -n 4

dig -t TXT $txt|grep "did=did:plc:"|head -n 1

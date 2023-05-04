#!/bin/zsh

txt=_atproto.$1

dig -t TXT $txt|grep "did=did:plc:"|head -n 1

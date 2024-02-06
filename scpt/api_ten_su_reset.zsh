#!/bin/zsh
host=https://api.syui.ai
pass=`cat $HOME/.config/atr/api_card.json|jq -r .password`
token=`cat $HOME/.config/atr/api_card.json|jq -r .token`

case $OSTYPE in
	darwin*)
		alias date="/opt/homebrew/bin/gdate"
		;;
esac

function ten_su_reset() {
	ten_data=`curl -sL "$host/users?itemsPerPage=3000"|jq ".|sort_by(.ten_su)|reverse|.[]|select(.ten_su != 0)"`
	ten_u_tmp=`echo $ten_data|jq -s`
	ten_n_tmp=`echo $ten_u_tmp|jq "length"`
	ten_n_tmp=$((ten_n_tmp - 1))
	#ten_n_tmp=5
	for ((i=0;i<$ten_n_tmp;i++))
	do
		u_i=`echo $ten_u_tmp|jq -r ".[$i].id"`
		u_a=`echo $ten_u_tmp|jq -r ".[$i].username"`
		u_s=`echo $ten_u_tmp|jq -r ".[$i].ten_su"`
		echo "---"
		echo "id : $u_i"
		echo "user : $u_a"
		echo "ten : $u_s"
		curl -X PATCH -H "Content-Type: application/json" -d "{\"ten\": false,\"token\":\"$token\", \"ten_su\": 0}" -s $host/users/$u_i
	done
}

ten_su_reset

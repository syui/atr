#!/bin/zsh

url=https://api.syui.ai
token=`cat $HOME/.config/atr/api_card.json|jq -r .token`
pass=`cat $HOME/.config/atr/api_card.json|jq -r .password`
f_reid_user=$HOME/.config/atr/txt/card_reid_user.txt
n=`cat $f_reid_user|wc -l`

for ((i=1;i<=$n;i++))
do
	uid=`cat $f_reid_user|awk "NR==$i"`
	r=`echo $(($RANDOM % 10))`
	if [ $r -eq 1 ];then
		card=`echo $(($RANDOM % 15))`
		cp=`echo $(($RANDOM % 300 + 50))`
	else
		card=0
		cp=`echo $(($RANDOM % 100 + 1))`
	fi

	ss=$(($RANDOM % 10))
	if [ 13 -ne $card ] && [ $ss -eq 1 ];then
		card=13
	fi

	s=$(($RANDOM % 2))
	if [ $s -eq 1 ];then
		s=super
		plus=$(($RANDOM % 500 + 200))
		cp=$((cp + plus))
	else
		s=normal
	fi
	if [ $card -eq 13 ];then
		plus=$(($RANDOM % 1000 + 300))
		cp=$((cp + plus))
	fi
	tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$card,\"status\":\"$s\",\"cp\":$cp,\"password\":\"$pass\"}" -s $url/cards`
	echo $tmp

	card=`echo $tmp|jq -r .card`
	cp=`echo $tmp|jq -r .cp`
	echo "[card]"
	echo "id : ${card}"
	echo "cp : ${cp}"
done

#!/bin/zsh

case $OSTYPE in
	darwin*)
		alias date="/opt/homebrew/bin/gdate"
		;;
esac

atr=$HOME/.cargo/bin/atr 
host=https://api.syui.ai
host_card=https://card.syui.ai/json/card.json
pass=`cat $HOME/.config/atr/api_card.json|jq -r .password`
token=`cat $HOME/.config/atr/api_card.json|jq -r .token`
handle=$1
username=`echo $1|cut -d . -f 1`
did=$2
cid=$3
uri=$4
opt=$5
pay=100
eat_file=$HOME/.config/atr/txt/nyancat_eat.txt
ran=`echo $(($RANDOM % 15))`

eat="🍺☕	🍵	🍶	🍼🍻	🍸	🍹	🍷	🍴	🍕	🍔	🍟	🍗	🍖	🍝🍛	🍤	🍱	🍣	🍥	🍙	🍘	🍚	🍜	🍲	🍢🍡	🍳	🍞	🍩	🍮	🍦	🍨	🍧	🎂	🍰	🍪🍫	🍬	🍭	🍯	🍎	🍏	🍊	🍋	🍒	🍇	🍉🍓	🍑	🍈	🍌	🍐	🍍	🍠	🍆	🍅	🌽"

eat=`echo $eat|grep "$opt"`


if [ -z "$eat" ];then
	ran=`echo $(($RANDOM % 3))`
	if [ $ran -eq 1 ];then
		body="|　キュー"
	elif [ $ran -eq 2 ];then
		body="|　ミュー"
	else
		body="|　ピャー"
	fi
	echo "uncooked"
	echo "A＿＿A
|・ㅅ・ |
|っ　ｃ|
$body
 U￣￣U"
exit
fi

echo "|    ${opt}    |" >> $eat_file

body_d="A＿＿A
|・ㅅ・ |
|っ　ｃ|
`tac $eat_file|grep -v '|        |'`
 U￣￣U"

function card_user(){
	all_data=`curl -sL "$host/users?itemsPerPage=3000"`
	data=`echo $all_data|jq ".[]|select(.username == \"$username\")"`
	uid=`echo $data|jq -r .id`
	aiten=`echo $data|jq -r .aiten`
	like=`echo $data|jq -r .like`
	ten_data=`echo $all_data|jq ".|sort_by(.aiten)|reverse|.[]|select(.aiten >= $pay)"`
	if [ -z "$ten_data" ] || [ -z "$aiten" ] || [ $aiten -le $pay ];then
		echo "aiten : $aiten >= $pay"
		echo "failed to buy food"
		echo "please : @yui.syui.ai /ten"
		exit
	else
		pay_s=$((aiten - pay))
		like_s=$((like + 1))
		if [ $pay_s -le 0 ] || [ -z "$pay_s" ];then
			echo "aiten : $aiten >= $pay"
			echo "failed to buy food"
			echo "please : @yui.syui.ai /ten"
			exit
		fi
		body_user=`echo "${aiten} : $aiten - $pay = $pay_s"`
	fi
}

function card_like() {
	if [ $like -gt 3 ] && [ $ran -eq 	1 ];then
		echo "happy!"
		su=`cat $eat_file|wc -l`
		su=$((su * 100))
		pay_s=$((aiten + su))
		body_user=`echo "${aiten} : $aiten + $su = $pay_s"`
		rm $eat_file
		echo "|    ${opt}    |" >> $eat_file
		body_d="A＿＿A
|・ㅅ・ |
|っ　ｃ|
`tac $eat_file|grep -v '|        |'`
 U￣￣U"
	fi
}

function card_pay(){
	link=https://card.syui.ai/$username
	text=`echo "$body_user\n$body_d"`
	desc="[$ten]"
	tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"like\":$like_s,\"token\":\"$token\", \"aiten\": $pay_s}" -s $host/users/$uid`
	echo "$text"
}

card_user
card_like
card_pay

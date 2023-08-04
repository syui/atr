#!/bin/zsh

case $OSTYPE in
	darwin*)
		alias date="/opt/homebrew/bin/gdate"
		;;
esac

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ] || [ -z "$5" ];then
	echo no option
	echo "/chara start"
	exit
fi

chara_qa="あなたは夢の中、不思議な世界が広がっています。
どんな世界でしょう。

1 : 遠くに見える廃墟が自然の森に飲み込まれる世界
2 : 賑やかな大都市、時間が光の速さで過ぎ去る世界
3 : 真っ白な空間に心で思ったものが創造される世界

数字を入れて答えてね。
/chara 数字"

chara_qb="あなたは、その世界を一つに染める力があります。
その一つはなんでしょう。

1 : 青空
2 : 文字
3 : 透明"

chara_qc="あなたは今、空を飛んでいます。
どこに向かって飛びますか?

1 : ぼんやりと浮かぶ月
2 : どこまでも遠くの地平線
3 : 輝く太陽"

chara_qd="
1 : 鉄をお金に変える
2 : 瞬間移動
3 : 巨大爆破"

chara_ba="
☑ 独特の感性
☑ 干渉を嫌う
☑ 異質のオーラを放つ
---"

chara_bb="
☑ 洗礼された感覚
☑ 不公正を嫌う
☑ バランス感覚に優れる
---"

chara_bc="
☑ 果敢に挑戦
☑ 独断を先行しがち
☑ 困難を乗り越える
---"

chara_bd="
☑ 面白いことが好き
☑ 仲間思い
☑ 行動力がある
---"

tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"ten_post\": \"$ten_char\", \"ten_kai\":0,\"ten_su\":$first_ten,\"ten\": true,\"token\":\"$token\"}" -s $host/users/$uid`
data_user_card=`curl -sL "$host/users/$uid/card?itemsPerPage=3000"`
ten_data=`curl -sL "$host/users?itemsPerPage=3000"|jq ".|sort_by(.ten_su)|reverse|.[]|select(.ten_su != 0)"`
data_user_card=`curl -sL "$host/users/$uid/card?itemsPerPage=3000"`

atr=$HOME/.cargo/bin/atr
host=https://api.syui.ai
host_card=https://card.syui.ai/json/card.json
#host_card_json=`curl -sL $host_card`

ran=$(($RANDOM % 3))

pass=`cat $HOME/.config/atr/api_card.json|jq -r .password`
token=`cat $HOME/.config/atr/api_card.json|jq -r .token`

handle=$1
did=$2
username=`echo $1|cut -d . -f 1`
cid=$3
uri=$4
option=$5

yui_did=did:plc:4hqjfn7m6n5hno3doamuhgef
all_data=`curl -sL "$host/users?itemsPerPage=3000"`
data=`echo $all_data|jq ".[]|select(.username == \"$username\")"`
uid=`echo $data|jq -r .id`
aiten=`echo $data|jq -r .aiten`
ten_post=`echo $data|jq -r .ten_post`
ten_su=`echo $data|jq -r .ten_su`
ten_kai=`echo $data|jq -r .ten_kai`
ten_delete=`echo $data|jq -r .ten_delete`
ten_bool=`echo $data|jq -r .ten`
day_at=`date +"%Y%m%d"`
nd=`date +"%Y%m%d" -d '1 days ago'`
ten_at_n=`date --iso-8601=seconds`
d=`date +"%Y-%m-%d"`
ten_at=`echo $data|jq -r .ten_at`
ten_at=`date -d "$ten_at" +"%Y-%m-%d"`
data_card=`curl -sL "$host/users/$uid/card?itemsPerPage=3000"`

# uri_post=`echo '{"uri":"at://did:plc:uqzpqmrjnptsxezjx4xuh2mn/app.bsky.feed.post/3k3zr5b336o2u","cid":"bafyreierpw23cxvx4e3cjzd3h6r4crz646zb2ana6cmmsxn4z5rpupl35e"}'|jq -r .uri|cut -d / -f 5`
# https://bsky.app/profile/$did/post/$uri_post
tmp_atr='{"uri":"at://did:plc:uqzpqmrjnptsxezjx4xuh2mn/app.bsky.feed.post/3k3zr5b336o2u","cid":"bafyreierpw23cxvx4e3cjzd3h6r4crz646zb2ana6cmmsxn4z5rpupl35e"}'

function chara_check(){
	#card_check=`echo $data_card|jq -r ".[]|select(.card == 48 or .card == 49 or .card == 50 or .card == 51 or .card == 52 or .card == 53)"`
	card_check=`echo $data_card|jq -r ".[]|select(.card == 54 or .card == 55 or .card == 56)"`
	if [ -n "$card_check" ];then
		echo you already have chara-card
		exit
	fi
}

function chara_start() {
	tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"ten_su\":0, \"ten_kai\":1, \"token\":\"$token\"}" -s $host/users/$uid`
	echo "$chara_qa"
	exit
}

function chara_post(){
	case $1 in
		ai)
			card=54
			text=$chara_ba
			title="[アイ]"
			desc="アイ・モード"
			;;
		moji)
			card=56
			text=$chara_bb
			title="[アイ]"
			desc="モジ・モード"
			;;
		zen)
			card=55
			text=$chara_bc
			title="[アイ]"
			desc="ゼン・モード"
			;;
	esac

	host_card=https://card.syui.ai/json/card.json
	host_card_json=`curl -sL $host_card`
	j=`echo $host_card_json|jq ".[]|select(.id == $card)"`
	img=`echo $j|jq -r .img`

	cp=$(($RANDOM % 1230))
	s=super
	skill=chara
	link="https://card.syui.ai/$username"

	card_check=`echo $data_card|jq -r ".[]|select(.card == $card)"`
	if [ -z "$card_check" ];then
		tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$card,\"status\":\"$s\",\"cp\":$cp,\"password\":\"$pass\",\"skill\":\"$skill\"}" -s $host/cards`
		card=`echo $tmp|jq -r .card`
		cp=`echo $tmp|jq -r .cp`
	fi
	tmp_atr=`$atr reply-og "$text" --cid $cid --uri $uri --img $img --title "$title" --description "$desc" --link $link`
 uri_post=`echo $tmp_atr|jq -r .uri|cut -d / -f 5`
	post_url="https://bsky.app/profile/$yui_did/post/$uri_post"
	ccid=`echo $tmp|jq -r .id`
	tmp=`curl -sL -X PATCH -H "Content-Type: application/json" -d "{\"url\":\"$post_url\",\"token\":\"$token\"}" $host/cards/$ccid`
	exit
}

function chara_plus() {
	case $ten_kai in
		2)
			chara_q=$chara_qb
			;;
		3)
			chara_q=$chara_qc
			;;
		#4)
		#	chara_q=$chara_qd
		#	;;
	esac
	echo "$chara_q"

	case $1 in
		1|2|3)
			tmp_su=$1
			ten_su=$((ten_su + $tmp_su))
			;;
	esac
	tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"ten_su\":$ten_su, \"ten_kai\":$ten_kai, \"token\":\"$token\"}" -s $host/users/$uid`

	case $ten_kai in
		4)
			if [ $ten_su -eq 9 ] || [ $ten_su -eq 8 ] || [ $ten_su -eq 7 ];then
				chara=zen
			elif [ $ten_su -eq 6 ];then
				chara=moji
			else
				chara=ai
			fi
			chara_post $chara
			;;
	esac
}

chara_check

case "$option" in
	start)
		chara_start
		;;
	1|2|3)
		ten_kai=$((ten_kai + 1))
		chara_plus $option
		;;
	*)
		echo "/chara start"
		echo "/chara 1,2,3"
		;;
esac

exit

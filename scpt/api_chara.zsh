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

chara_qa="家にゴキブリが出ました。
あなたはどうしますか?
1 : 叩き潰す
2 : スプレーを吹きかける
3 : 話しかけて毒の餌をあげる
4 : 外に逃がす

数字を入れて答えてね。
/chara 数字"

chara_qb="行動を起こそうとしたあなた。
しかし、近くにいた親子が悲鳴を上げ、母親がゴキブリを退治しました。
小さな男の子はゴキブリが死んじゃったと泣いています。
その時、あなたはどう思いましたか?
1 : 仕方ないよね
2 : 泣き虫だな
3 : 昔の自分だ
4 : 自分と同じ"

chara_qc="潜んでいたもう一匹のゴキブリ。
あなためがけて飛んできます。
とっさに避けようするあなたでしたが、すっ転んで頭を強く打ち付けます。
...気がつくとそこは異世界。
誰もいない不思議な空間です。
あなたが最初に手に取るのは?
1 : 剣
2 : 盾
3 : 魔法の杖
4 : モンスターボックス"

chara_qd="あなたの選択で不思議な力が宿りました。
あなたの能力は?
1 : 鉄をお金に変える
2 : 瞬間移動
3 : 巨大爆破
4 : 空を飛ぶ"

chara_ba="
☑ 情報の整理や分析が好き
☑ 独立精神が高く、個人主義
☑ 好奇心が旺盛
---"

chara_bb="
☑ 愛と自由
☑ お昼寝してる
☑ 優しさと純粋さを併せ持つ稀有な存在
---"

chara_bc="
☑ 優秀である
☑ 能力が高い
☑ 孤独になりがち
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
	card_check=`echo $data_card|jq -r ".[]|select(.card == 48 or .card == 49 or .card == 50 or .card == 51 or .card == 52 or .card == 53)"`
	if [ -n "$card_check" ];then
		echo you already have chara-card
		#exit
	fi
}

function chara_start() {
	tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"ten_su\":0, \"ten_kai\":1, \"token\":\"$token\"}" -s $host/users/$uid`
	echo "$chara_qa"
	exit
}

function chara_post(){
	case $1 in
		zen)
			card=48
			text=$chara_ba
			title="[ゼン]"
			desc="知恵"
			;;
		ai)
			card=49
			text=$chara_bb
			title="[アイ]"
			desc="意思"
			;;
		octo)
			card=51
			text=$chara_bc
			title="[オクトカット]"
			desc="才能"
			;;
		kyosuke)
			card=52
			text=$chara_bd
			title="[キョウスケ]"
			desc="勇気"
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
	tmp=`curl -X POST -H "Content-Type: application/json" -d "{\"owner\":$uid,\"card\":$card,\"status\":\"$s\",\"cp\":$cp,\"password\":\"$pass\",\"skill\":\"$skill\"}" -s $host/cards`
	card=`echo $tmp|jq -r .card`
	cp=`echo $tmp|jq -r .cp`
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
		4)
			chara_q=$chara_qd
			;;
	esac
	echo "$chara_q"

	case $1 in
		1|2|3|4)
			tmp_su=$1
			if [ $ten_kai -eq 2 ] && [ $tmp_su -eq 1 ];then
				tmp_su=0
			fi
			if [ $ten_kai -eq 3 ] && [ $tmp_su -eq 2 ];then
				tmp_su=0
			fi
			if [ $ten_kai -eq 2 ] && [ $tmp_su -eq 4 ];then
				tmp_su=5
			fi
			if [ $ten_kai -eq 3 ] && [ $tmp_su -eq 4 ];then
				tmp_su=5
			fi
			ten_su=$((ten_su + $tmp_su))
			;;
	esac
	tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"ten_su\":$ten_su, \"ten_kai\":$ten_kai, \"token\":\"$token\"}" -s $host/users/$uid`

	case $ten_kai in
		5)
			if [ $ten_su -ge 15 ];then
				chara=ai
			elif [ $ten_su -ge 11 ];then
				chara=zen
			elif [ $ten_su -ge 6 ];then
				chara=octo
			else
				chara=kyosuke
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
	1|2|3|4)
		ten_kai=$((ten_kai + 1))
		chara_plus $option
		;;
	*)
		echo "/chara start"
		echo "/chara 1,2,3,4"
		;;
esac

exit

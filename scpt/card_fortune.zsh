#!/bin/zsh

atr=$HOME/.cargo/bin/atr 
url_j=https://card.syui.ai/json/card.json
tcid=$HOME/.config/atr/txt/tmp_notify_cid.txt

handle=$1
did=$2
cid=$3
uri=$4

if [ ! -d $HOME/.config/atr/txt ];then
	mkdir -p $HOME/.config/atr/txt
fi

case $OSTYPE in
	darwin*)
		alias date="/opt/homebrew/bin/gdate"
		;;
esac

url=https://api.syui.ai
username=`echo $1|cut -d . -f 1`
link=https://card.syui.ai/$username
ran=$(($RANDOM % 10))

if [ $ran -eq 1 ];then
	uranai="今日の運勢をルーン占いでやってください。結果を120文字以内で教えてください"
else
	uranai="今日の運勢をタロット占いでやってください。結果を120文字以内で教えてください"
fi

uid=`curl -sL "$url/users?itemsPerPage=2000"|jq ".[]|select(.username == \"$username\")"|jq -r .id`

if [ -z $uid ] || [ "$uid" = "null" ];then
	body=`$atr chat "$uranai" -c`
	body=`echo "占いにはアイのカードが3枚以上必要です\n\n$body"`
	if [ "`cat $tcid`" != "$cid" ];then
		if $atr r "$body" -c $cid -u $uri;then
			echo $cid >! $tcid
		fi
	fi
	exit
fi

data=`curl -sL "$url/users/$uid"`
data_u=`curl -sl "$url/users/$uid/card?itemsperpage=2000"`
luck_at=`echo $data|jq -r .luck_at`
luck_at_n=`date --iso-8601=seconds`
luck_at=`date -d "$luck_at" +"%Y%m%d"`
day_at=`date +"%Y%m%d"`
nd=`date +"%Y%m%d" -d '1 days ago'`

if [ "$luck_at" = "$day_at" ];then
	body=`$atr chat "$uranai" -c`
	if [ "`cat $tcid`" != "$cid" ];then
		if $atr r "$body" -c $cid -u $uri;then
			echo $cid >! $tcid
		fi
	fi
	exit
fi

cp_i=`echo $data_u |jq -r "sort_by(.cp) | reverse|.[].card"|sort|uniq|sed -e '1d'`
cp_n=`echo $cp_i|wc -l`

if [ 3 -gt $cp_n ];then
	body=`$atr chat "$uranai" -c`
	body=`echo "占いにはアイのカードが3枚以上必要です\n\n$body"`
	if [ "`cat $tcid`" != "$cid" ];then
		if $atr r "$body" -c $cid -u $uri;then
			echo $cid >! $tcid
		fi
	fi
	exit
fi

ran=$(($RANDOM % $cp_n + 1))
luck=$(($RANDOM % 8))
sub=$(($RANDOM % 15))
card=`echo $cp_i|awk "NR==$ran"`

if [ $sub -eq $card ];then
	sub="x2"
else
	sub=`curl -sL $url_j|jq -r ".[]|select(.id == $sub)|.p"`
fi
j=`curl -sL $url_j|jq ".[]|select(.id == $card)"`
img=`echo $j|jq -r .img`

if [ -z $img ] || [ "$img" = "null" ];then
	j=`curl -sL $url_j|jq ".[]|select(.id == 0)"`
	img=`echo $j|jq -r .img`
fi

test_ran=`echo $(($RANDOM % 3))`

#text="アイ・カード占い"
case $test_ran in
	1)
		text=`$atr chat "アイのカード占いを作ってやってみて。感じる答えを出して。できれば140文字以内でお願い。" -c`
		;;
	2)
		text=`$atr chat "今、アイが自分で考えた占いやってみて。気分が乗らなかったらやらなくていいよ。できれば140文字以内で答えてね。" -c`
		;;
	*)
		text=`$atr chat "今のアイの気分で適当に占ってみて。できれば140文字以内で答えてね。" -c`
		;;
esac

title=`echo $j|jq -r .h`
title="[${title}]"
#desc=`echo $j|jq -r .p`

if [ 0 -eq $luck ];then
	desc="0"
fi

if [ 1 -eq $luck ];then
	desc="1"
fi

if [ 2 -eq $luck ];then
	desc="2"
fi

if [ 3 -eq $luck ];then
	desc="3"
fi

if [ 4 -eq $luck ];then
	desc="4"
fi
if [ 5 -eq $luck ];then
	desc="5"
fi

if [ 6 -eq $luck ];then
	desc="6"
fi

if [ 7 -eq $luck ];then
	desc="7"
fi

desc=`echo "アイ数字は${luck}"`

if [ "`cat $tcid`" != "$cid" ];then
	if $atr reply-og "$text" --cid $cid --uri $uri --img $img --title "$title" --description "$desc" --link $link;then
		echo $cid >! $tcid
	fi
fi

pass=`cat $HOME/.config/atr/api_card.json|jq -r .password`
token=`cat $HOME/.config/atr/api_card.json|jq -r .token`

if [ $luck -eq 7 ];then
	tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"luck_at\":\"$luck_at_n\",\"token\":\"$token\",\"luck\": $luck, \"next\": \"$nd\"}" -s $url/users/$uid`
else
	tmp=`curl -X PATCH -H "Content-Type: application/json" -d "{\"luck_at\":\"$luck_at_n\",\"token\":\"$token\",\"luck\": $luck}" -s $url/users/$uid`
fi
exit

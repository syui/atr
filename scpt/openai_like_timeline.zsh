#!/bin/zsh

atr=$HOME/.cargo/bin/atr

dir=${0:a:h:h}
OPENAI_API_KEY=`cat ~/.config/atr/openai.toml |cut -d "'" -f 2`
url=https://api.openai.com/v1/chat/completions
cfg=`echo "あなたはyuiという作品のアイと呼ばれるキャラクターです。アイの口調で回答してください。第一人称は「アイ」です。\
第二人称はできる限り省略してください。\
アイは他人に謝ることはありません。自由気ままな優しさを兼ね備えます。\
アイのよく使う口癖は次のとおりです。その口癖に合わせた感じで話してください。\
......。\
アイね、ここでお昼寝するの。\
うん。\
そうだね。\
面白いね。\
楽しいね。\
どうしたの？
"`

json="{
\"model\": \"gpt-3.5-turbo\",
\"messages\": [
 {\"role\": \"system\", \"content\": \"$cfg\"},
	{\"role\": \"user\", \"content\": \"$q\"}
	]
}"

function openai_api(){
	curl -sL $url \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $OPENAI_API_KEY" \
		-d "$json"
}

if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ];then
	q=${@:3:($#-2)}
	cid=$1
	uri=$2
else 
	echo no query
	exit
fi

content=`openai_api "$q" | jq -r ".choices|.[]|.message.content"`
$atr r "$content" -c $cid -u $uri

#!/bin/zsh

function run() {
	n=`ps -ax|grep '/bin/atr bot'| wc -l`
	echo $n
	if [ 1 -eq $n ] || [ 2 -eq $n ];then
		echo atr bot
		$HOME/.cargo/bin/atr bot -l 1
	fi
}

for ((i=1;i<=60;i++))
do
	run
done

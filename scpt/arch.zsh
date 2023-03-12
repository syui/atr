#!/bin/zsh

home=/home/syui
name=arch
a=$home/$name

function arch_in(){
	mkdir -p $a
	sudo pacstrap -c $a base
	#sudo echo pts/0 >> $a/etc/securetty
	#sudo echo pts/1 >> $a/etc/securetty
	sudo rm -rf /var/lib/machines/$name
	sudo rm -rf /var/lib/machines/${name}back
	sudo mv $a /var/lib/machines/
	sudo machinectl clone arch archback
}

function arch_rm(){
	sudo machinectl remove $name
}

function arch_up(){
	sudo machinectl poweroff $name > /dev/null 2>&1
	sleep 5
	sudo machinectl terminate $name > /dev/null 2>&1
	sleep 5
	sudo machinectl start ${name}back
	sleep 5
	ssh ${name}back pacman -Syu --noconfirm
	sleep 5
	sudo machinectl poweroff ${name}back
}

function arch_st(){
	sudo machinectl start $name
}

function arch_of(){
	sudo machinectl poweroff $name
}

function arch_ex(){
	sudo machinectl shell $name
	$1
	poweroff
}

function arch_re(){
	sudo machinectl poweroff $name  > /dev/null 2>&1
	sleep 5
	sudo machinectl terminate $name > /dev/null 2>&1
	sleep 5
	sudo machinectl remove $name
	sleep 5
	sudo machinectl clone ${name}back $name
	sleep 5
	sudo machinectl start $name
}

case "$1" in
	"update"|"-u")
		arch_up
		arch_re
		echo "machinectl update done"
		;;
	"reset"|"-r")
		arch_re
		echo "machinectl reset done"
		;;
	*)
		sudo machinectl start $name
		t=`ssh $name "$*"`
		if [ -z "$t" ];then
			ssh -tt $name "$*"
		else 
			echo "$t"
		fi
		;;
esac

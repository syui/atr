#!/bin/zsh

dir=${0:a:h}
mkdir -p $dir/png
f=$dir/png/t.png
f_sleep=$dir/png/sleep
cfg=$dir/stable_diffusion_prompt.j
cfg_did=$dir/stable_diffusion_did.txt
opt_af=$dir/stable_diffusion_a.txt
opt_bf=$dir/stable_diffusion_b.txt
opt_allf=$dir/stable_diffusion_all.txt

if [ ! -f $cfg_did ];then
	touch $cfg_did
fi

did=$1
admin=did:plc:uqzpqmrjnptsxezjx4xuh2mn

if [ ! -f $cfg ];then
	echo no file $cfg
	exit
fi

opt_a=`echo $@|cut -d ' ' -f 2`
opt_b=`echo $@|cut -d ' ' -f 3`

#case "$opt_b" in
#	bluesky|sky|field|girl|anime|universe|earth|bird|miku|ai|yui|card|blue|cat)
#		;;
#	*)
#		if [ -n "$opt_b" ] && [ "$did" != "$admin" ];then
#			opt_b=nyancat
#		fi
#		;;
#esac

echo $opt_a >! $opt_af
echo $opt_b >! $opt_bf
echo $@ >! $opt_allf

case "$opt_a" in
	-p|p)
		q="$opt_b , masterpiece, best quality, 8k wallpaper Highly, cinematic Lighting, cinematic Beautiful"
		;;
	-t|t)
		tag=$opt_b
		json=`cat $cfg|jq ".[]|select(.tag == \"${tag}\")"`
		if [ -z "$json" ] || [ -z "$tag" ];then
			echo no tag
			exit
		fi
		json=`echo $json|jq -s`
		n=`echo $json|jq "length"`
		n=$((RANDOM % n))
		q=`echo $json|jq -r ".[$n].body"`
		#m=`echo $json|jq -r ".[$n].model"`
		;;
	*)
		n=`cat $cfg|jq "length"`
		n=$((RANDOM % n))
		q=`cat $cfg|jq -r ".[$n].body"`
		;;
esac

model_s="model
coharu
flat2d
pastelmix
pvcstyle"
model_r=$((RANDOM % `echo "$model_s"|wc -l` + 1))
m=`echo "$model_s"|awk "NR==$model_r"`

case $1 in
	-pm)
			m=$2
			q=`echo $@ | cut -d ' ' -f 3-`
		;;
esac

if [ -z "$q" ];then
	echo no prompt
	exit
fi
if [ -z "$m" ];then
	m=model
fi

echo $q
echo $m

function run(){
	if [ -f $f_sleep ];then
		rm $f_sleep
	fi
	ssh ue "conda activate ldm;cd ./stable-diffusion/;python safe.py \'${q}\' ${m}"
	scp -r ue:stable-diffusion/t.png $f
	if [ $? -ne 0 ];then
		touch $f_sleep
	fi
}

if [ -n "`cat $cfg_did| grep -x $did`" ] && [ "$did" != "$admin" ];then
	rm $f
else
	echo "\n$did" >> $cfg_did
	run
fi

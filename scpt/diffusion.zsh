#!/bin/zsh

dir=${0:a:h}
f=$dir/diffusion_prompt.txt

seed=$RANDOM

sd_prompt_a="masterpiece, high quality, very_high_resolution, large_filesize, full color"

## kawaii girl random prompt
#	ra=$(($RANDOM % 2 + 1))
#	rp="beautiful kawaii "`echo "little girl,girl"|cut -d , -f $ra|tr -d ,`
#	rb=$(($RANDOM % 3 + 1))
#	rbp="with "`echo "gold,silver,black"|cut -d , -f $rb|tr -d ,`" hair"
#	rc=$(($RANDOM % 4 + 1))
#	rcp=`echo "wavy,long,straight,"|cut -d , -f $rc|tr -d ,`
#	rd=$(($RANDOM % 3 + 1))
#	rdp="in "`echo "fluttery white onepice,simple white onepice,normal white school uniform"|cut -d , -f $rd|tr -d ,`
#	echo $sd_prompt_a, $rp $rdp $rcp $rbp 

if [ -n "$1" ];then
	echo $sd_prompt_a $* >! $f
	cat $f
	q=`cat $f`
else
	echo no query
	exit
fi

rm -rf $dir/png
mkdir -p $dir/png
ssh win Remove-Item -Recurse -Force stable-diffusion/outputs
ssh win Remove-Item -Recurse -Force msbot
ssh win mkdir stable-diffusion/outputs
ssh win mkdir msbot
ssh win "conda activate ldm;cd ./stable-diffusion/;python optimizedSD/optimized_txt2img.py --prompt \"${q}\" --H 512 --W 512 --seed $seed --n_iter 1 --n_samples 1 --ddim_steps 50"
diff_dir=`ssh win ls stable-diffusion/outputs/txt2img-samples -Name|cut -b 1-2`
ssh win "cd stable-diffusion/outputs/txt2img-samples;mv $diff_dir* $diff_dir -Force;mv $diff_dir/*.png ~/msbot/t.png -Force"
ssh win ".\scoop\apps\imagemagick\current\convert.exe msbot/t.png msbot/t.jpg"
scp -r win:msbot/t.jpg $dir/png/t.jpg

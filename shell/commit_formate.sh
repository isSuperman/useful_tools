#!/bin/bash

#
# Copyright (c) 2019-2021 IsSuperman
# https://github.com/IsSuperman/op-firemae
# File name: commit_formate.sh
# Description: 格式化commit信息lede专用
# $1 仓库所有者名字
# $2仓库名字
#

now=$(date +"%Y-%m-%d")
now_year=$(date +"%Y")
branches=(lede luci packages helloworld)

nbs=(0 ① ② ③ ④ ⑤ ⑥ ⑦ ⑧ ⑨ ⑩ ⑪ ⑫ ⑬ ⑭ ⑮ ⑯ ⑰ ⑱ ⑲ ⑳ ㉑ ㉒ ㉓ ㉔ ㉕ ㉖ ㉗ ㉘ ㉙ ㉚ ㉛ ㉜ ㉝ ㉞ ㉟ ㊱ ㊲ ㊳ ㊴ ㊵ ㊶ ㊷ ㊸ ㊹ ㊺ ㊻ ㊼ ㊽ ㊾ ㊿)


if [[ "$#" < 2 ]]
then
  echo "给定参数缺失"
  exit 1
fi

## Funvtions
get_commit_2str(){
	for branch in branches
	do
		curl -so get_commit_${branch}.log "https://api.github.com/repos/$1/$2/commits?sha=$branch" 
		sed -i 's/\[//' get_commit_${branch}.log
		sed -i 's/\]//' get_commit_${branch}.log
		sed -i 's#{##' get_commit_${branch}.log
		sed -i 's#}##' get_commit_${branch}.log
		sed -i '/^$/d' get_commit_${branch}.log
		sed -i 's/^[ \t]*//' get_commit_${branch}.log
		sed -i ':a;N;$!ba;s/\n//g' get_commit_${branch}.log
		grep -Po '"commit":.*?(?=","tree)' get_commit_${branch}.log > str_commit_${branch}.log
		sed -i 's/\\n\\n.*$//g' str_commit_${branch}.log
	done
}

get_latest_date(){
	for branch in branches
	do
		grep -Po '(?<="date": ").*?(?=T)' str_commit_${branch}.log | sed -n '1p' | tee -a recent_d.log
	done
	while read line
	do
		echo "$(date -d ${line} +%s)" >> recent_d_sec.log
	done
	max=$(sed -n '1p' recent_d_sec.log)
	while read line
	do
		if [ $max -lt $line ]
		then
			max=$line
		fi
	done < "./recent_d.log"
	recent_date=`date -d @$max "+%Y-%m-%d"`
	echo "${recent_date}" > recent_date.log
}

generate_info(){
	for branch in branches
	do
		while read line
		do	
			result=$(echo $line | grep "$recent_date")
			
			if [[ "$result" != "" ]]
			then 
				echo $line >> day_${branch}.log
			else
				echo "nothing" >> day_${branch}.log
			fi
		done < "./str_commit.log"

		grep -Po '(?<="message": ").*?(?=$)' day_${branch}.log > day2_${branch}.log
		sed -i 's#).*$#)#g' day2_${branch}.log

		dayy=0

		while read line
		do
			dayy=$(($dayy+1))
			if [[ "$dayy" == 1 ]]
			then
				if [[ "${branch}" == "lede" ]]
				then
					echo "\- ${branch}:\n${nbs[dayy]} ${line}" >> day3.log
				else
					echo "\n\- ${branch}:\n${nbs[dayy]} ${line}" >> day3.log
				fi
				
			else
				echo "\n${nbs[dayy]} ${line}" >> day3.log
			fi
		done < "./day2_${branch}.log"
	done
}

formate_result(){
	sed -i "s/${now_year}-//g" recent_date.log
	sed -i 's/\-/\\./g' recent_date.log
	sed -i ':a;N;$!ba;s/\n//g' day3.log
	sed -i 's/\-/\\-/g' day3.log
	sed -i 's/\./\\./g' day3.log		
	sed -i 's/(/\\(/g' day3.log
	sed -i 's/)/\\)/g' day3.log
	sed -i 's/\#/\\#/g' day3.log
	sed -i 's/<[^>]*>//g' day3.log
	sed -i 's#>=#\\>\\=#g' day3.log
	sed -i 's#<=#\\<\\=#g' day3.log
	sed -i 's#\\([^)]*)##g' day3.log
	sed -i 's/\_/\\-/g' day3.log		
}

# Call funtions
get_commit_2str
get_latest_date
formate_result

sed -i $'s/\'//g' day3.log


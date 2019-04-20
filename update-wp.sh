#!/bin/bash
which wp
if [ $? -gt 0 ]; then
	echo "wp-cli를 설치하고 다시 실행해 주세요. wp 명령어로 실행하게 설정돼 있어야 합니다."
	exit 1
fi

base_dir=$(dirname $0)
source "$base_dir/config.sh"

for dir in "${SITE_DIRS[@]}";
do
	cd $dir
	if [ $? -eq 0 ]; then
		echo -e "\n=== ${dir} ===\n"
	else
		echo -e "\n=== ${dir}은 없습니다 ===\n"
		continue
	fi
	
	git pull
	git status
	is_modified=$(git status | wc -l | tr -d '[:space:]')
	if [ $is_modified -gt 4 ]; then
		echo -e "\n${dir}에 변경된 파일이 있으므로 업데이트하지 않습니다.\n"
		continue;
	fi

	wp core update
	wp plugin update --all
	wp theme update --all
	wp language core update
	wp language plugin update --all
	wp language theme update --all

	is_updated=$(git status | wc -l | tr -d '[:space:]')
	if [ $is_updated -gt 4 ]; then
		echo -e "\n${dir}: 변경된 파일을 커밋하고 푸시합니다.\n\n"
		git add .
		git commit -m 'wp update'
		git push
	fi
done
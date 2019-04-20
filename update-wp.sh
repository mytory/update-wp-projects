#!/bin/bash
which wp
if [ $? -gt 0 ]; then
	echo "Install wp-cli and re-run. wp-cli command must be wp."
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
		echo -e "\n=== No ${dir} ===\n"
		continue
	fi
	
	git pull
	git status
	is_modified=$(git status | wc -l | tr -d '[:space:]')
	if [ $is_modified -gt 4 ]; then
		echo -e "\n${dir} has modified files. Do not update.\n"
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
		echo -e "\n${dir}: It will add, commit, push updated files.\n\n"
		git add .
		git commit -m 'wp update'
		git push
	fi
done
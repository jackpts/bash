#!/usr/bin/env bash

#Composed by Yauheni Pauliukanets ypauliukanets@edmunds.com
#To make fast cleanup of a/b testing files [mostly on /sites-groundwork repo].

#Color Constants
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

#Path Constants
EXCLUDE_DIRS='--exclude-dir=.git --exclude-dir=.idea'
SCAFFOLD_DIR=~/git/sites-groundwork

if [ -z "$1" ]; then
	echo -e "${RED}Please specify pattern for a/b testing cleanup procedure!"
	echo -e "${GREEN}Example:${YELLOW} ab_cleanup -footprint-mobile"
	echo -e "${CYAN}(without asterisks and quotes)"

else
	cd $SCAFFOLD_DIR

	PATTERN='*'$1'*'
	echo -e "${CYAN}Used pattern:${GREEN} $PATTERN ${NC}"
	search_count=`find . -name $PATTERN | wc -l`

	if (( $search_count > 0 )); then
		echo -e "${RED}Files found:${YELLOW}"
		find . -name $PATTERN
		echo -e "${RED}Files count: ${GREEN} $search_count ${NC}"
	else
		echo -e "${RED}No files found with this pattern.${NC}"
	fi

	ref_count=`grep -rnw . -e $1 $EXCLUDE_DIRS | wc -l`

	if (( $ref_count > 0 )); then
		echo -e "${RED}References:${YELLOW}"
		grep -rnw . -e $1 $EXCLUDE_DIRS
		echo -e "${RED}References Count: ${GREEN} $ref_count ${NC}"
	else
		echo -e "${RED}No References found.${NC}"
	fi

	if (( $search_count > 0 )); then
		echo -e "${CYAN}Do you want to erase all these $search_count files?"
		read -p "Are you sure? <Y/N> " prompt

		if [[ $prompt =~ [yY](es)* ]]; then
			echo -e "${YELLOW}ERASE choosen."
			erased=`find . -name $PATTERN -exec rm -f {} \; 2>cleanup_ab_test.err`
			not_erased=$(cat cleanup_ab_test.err | grep 'cannot remove' | wc -l)

			if (( $not_erased > 0 )); then
				echo -e "${RED} $not_erased items not erased because of error:${CYAN}"
				cat cleanup_ab_test.err | grep 'cannot remove'
			else
				echo -e "${YELLOW}$search_count files erased. Bye!${RED}"
			fi

			if [ -f cleanup_ab_test.err ]; then
				rm cleanup_ab_test.err
			fi

			echo -e "${GREEN}Git Status: ${RED}"
			git status | grep deleted
		else
			echo -e "${GREEN}Left untouched. Exit."
		fi

	else
		echo -e "${CYAN}Nothing to cleanup. Exit."
	fi
fi
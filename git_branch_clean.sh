#!/bin/bash

#Composed by ypauliukanets@edmunds.com
#To clean up all local branches already merged in origin

#Color Constants
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

ARRAY=()

#check if it's a git repo
if [ -d .git ]; then
  echo "Git repository found."
else
  if [[ -d $1 ]]; then
	  cd $1
	  if [ ! -d .git ]; then
	  	 echo -e "${RED}Wrong git repository as a parameter!"
	  	 echo -e "${RED}Please define it as a parameter or put this file into this repo.${NC}"
	  	 exit
	  fi
  else
  	  echo -e "${RED}This is not a git repository!"
	  echo -e "${RED}Please define it as a parameter or put & run this script into this repo.${NC}"
	  exit
  fi
fi

#cd master and clean up all outdated remote branches (already merged and/or deleted)
git checkout master
git remote update --prune origin

#remote_branches=`git remote show origin | grep -v 'master'`
remote_branches=`git branch -r | grep -v 'master'`
local_branches=`git branch | grep -v 'master'`

for x in $local_branches
	do
		if [[ $remote_branches == *$x* ]]
			then echo -e "${CYAN}$x ${GREEN} has remote.."
			else
				echo -e "${RED}$x ${YELLOW} has no remote and can be deleted."
				ARRAY+=($x)
		fi
	done

if [[ -n $ARRAY ]]; then
	echo -e "${NC}-----------------------------"
	for a in ${ARRAY[@]}
		do
			echo $a
		done
	echo -e "-----------------------------"

	echo -e "${PURPLE}Delete all these locals?${NC}"
	read -p "<Y/N>" prompt

	if [[ $prompt =~ [yY](es)* ]]; then
		echo -e "${YELLOW}ERASE choosen..."
		for d in ${ARRAY[@]}
			do
				echo -e "${RED}$d ${YELLOW}deleting..."
				git branch -D $d
			done
		 echo -e "${PURPLE}All local branches has been deleted.${NC}"
	else
		echo -e "${GREEN}Keep untouched.${NC}"
	fi
else
	echo -e "${PURPLE}Sorry, nothing to clean up here!${NC}"
fi
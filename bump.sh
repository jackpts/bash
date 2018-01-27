#!/bin/bash

#Composed by ypauliukanets@edmunds.com
#To make fast assets bump/check b/w Assets and Scaffold repo

#Color Constants
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

#Path Constants
ASSETS_DIR=~/git/edmunds-groundwork-assets
SCAFFOLD_DIR=~/git/sites-groundwork
SCAFFOLDATOM_DIR=~/git/sites-groundwork/scaffold/groundwork/content/groundwork/assets-version

ASSETS_VER=0
SCAFFOLD_VER=0

if [ -z "$1" ]; then
	echo -e "${RED}Please specify input parameter!"
	echo -e "${GREEN}Example:${YELLOW} bump check ${NC}[check differences of versions in 2 repos]"
	echo -e "${GREEN}Example:${YELLOW} bump pull ${NC}[pull from both repos & check]"
	echo -e "${GREEN}Example:${YELLOW} bump replace ${NC}[pull & check & replace, but not push]"
	echo -e "${GREEN}Example:${YELLOW} bump push ${NC}[push latest assets to Scaffold]"
else
	function pull() {
		cd $ASSETS_DIR
		echo -e "${YELLOW}Pulling from Assets...${GREEN}"
		git checkout master
		git pull
		cd $SCAFFOLD_DIR
		echo -e "${YELLOW}Pulling from Scaffold...${GREEN}"
		git checkout master
		git pull
	}
	function checkVersion() {
		cd $ASSETS_DIR
		ASSETS_VER=`cat package.json | grep version | egrep -o '[[:digit:]]{4}'`
		cd $SCAFFOLDATOM_DIR
		SCAFFOLD_VER=`cat index.atom | grep assetsVersion | egrep -o '[[:digit:]]{4}'`
		echo -e "${CYAN}ASSETS Version:${GREEN} $ASSETS_VER"
		echo -e "${CYAN}SCAFFOLD Version:${GREEN} $SCAFFOLD_VER"
		if [[ $ASSETS_VER > $SCAFFOLD_VER ]]; then
			echo -e "${RED}ASSETS > SCAFFOLD! PUSH REQUIRED!${NC}"
			return 1
		else
			echo -e "${YELLOW}No PUSH required.${NC}"
			return 0
		fi
	}

	function replace() {
		echo -e "${YELLOW}Replacing..."
		REPLACED=s/$SCAFFOLD_VER/$ASSETS_VER/g
		sed -i -e $REPLACED $SCAFFOLDATOM_DIR/index.atom
	}

	function pushVersion() {
		replace

		git checkout master
		local_branch=git branch | grep bump-assets
		if [[ local_branch -ge 11 ]]; then
			git branch -D bump-assets
		fi

		git checkout -b "bump-assets"
		git commit -m "Bump Assets Version up to $ASSETS_VER"
		git push origin bump-assets
	}

	if [[ $1 == *"pull"* ]]; then
		pull
		checkVersion
	fi

	if [[ $1 == *"check"* ]]; then
		checkVersion
	fi

	if [[ $1 == *"replace"* ]]; then
		#pull
		checkVersion
		if [ "$?" -eq 1 ]; then
			replace
			echo -e "${GREEN}Checking Again..."
			checkVersion
		else
			echo -e "${YELLOW}No Replacing required..."
		fi
	fi

	if [[ $1 == *"push"* ]]; then
		echo -e "${GREEN}Checking if PUSH required..."
		checkVersion
		if [ "$?" -eq 1 ]; then
			pushVersion
			#echo -e "${GREEN}Checking Again..."
			#checkVersion
		fi

	fi

fi



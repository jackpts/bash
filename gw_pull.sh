#!/bin/bash

#Composed by Yauheni Pauliukanets ypauliukanets@edmunds.com
#To make fast PULL from typical Groundwork repos (Assets/Scaffold/CMS-PROD) and Assets start.
#Change Path Constants by your own

# constant part!
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

#Path Constants
ASSETS_DIR=~/git/edmunds-groundwork-assets
SCAFFOLD_DIR=~/git/sites-groundwork
CMS_DIR=~/git/cms-edmunds-prod


if [[ $1 =~ ^(-npm|--npm|npm)$ ]] 
	then
		echo -e "${GREEN}npm i${YELLOW} will be running later..${NC}"
	else
		echo -e "${YELLOW}NOTE: pass ${GREEN}-npm${YELLOW} parameter to include running ${GREEN}npm i${YELLOW} command${NC}"	
fi

cd $CMS_DIR
git checkout master
echo -e "${GREEN}PULL from ${RED}CMS-PROD${GREEN} started...${NC}"
git pull
echo -e "${GREEN}PULL from ${RED}CMS-PROD${GREEN} complete${NC}"
cd $SCAFFOLD_DIR
git checkout master
echo -e "${GREEN}PULL from ${RED}Scaffold${GREEN} started...${NC}"
git pull
echo -e "${GREEN}PULL from ${RED}Scaffold${GREEN} complete${NC}"
cd $ASSETS_DIR
git checkout master
echo -e "${GREEN}PULL from ${RED}Assets${GREEN} started...${NC}"
git pull
echo -e "${GREEN}PULL from ${RED}Assets${GREEN} complete${NC}"

if [[ $1 == *"npm"* ]]; then
	echo -e "${GREEN}NPM Install from ${RED}Assets${GREEN} started...${NC}"
	npm i
	echo -e "${GREEN}NPM Install from ${RED}Assets${GREEN} complete${NC}"
	#read -p "Press enter to run Assets Run Dev"
	echo -e "${GREEN}Press any key to run Assets${NC}"
	read -n 1 -s -p "Run Dev"
fi

npm run dev

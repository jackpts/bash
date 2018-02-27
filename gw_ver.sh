#!/bin/bash

#Composed by ypauliukanets@edmunds.com
#To get latest groundwork stable image number from kingpin
#And link to Tomcat .WAR file image to download.

#NOTE: `curl` and `python` should be installed

#Color Constants
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color


GW_VER=`curl http://kingpin/api/docker/environment/qa-21/artifact/groundwork-web | python -c "import sys, json; print (json.load(sys.stdin)[0]['image'])" | egrep -o '[[:digit:]]+.[[:digit:]]+.[[:digit:]]+$'`
echo -e "${YELLOW}The Latest GW Version is: ${RED}${GW_VER}"
echo -e "${YELLOW}Tomcat WAR Image Link: ${GREEN}http://nexus.prod-admin11.vip.aws1/nexus/service/local/artifact/maven/redirect?r=edmunds-release&g=com.edmunds.sites&a=groundwork-web&v=${GW_VER}&e=war${NC}"
echo -e "${YELLOW}Docker Container Image: ${GREEN}699349871153.dkr.ecr.us-east-1.amazonaws.com/groundwork-web:${GW_VER}${NC}"

#Check if docker's service is running
if (( $(ps -ef | grep -v grep | grep docker | wc -l) > 0 ))
then
	Docker_Ver=`docker images | grep groundwork | awk '{ print $2 }' | head -n 1`
	echo -e "${YELLOW}Current GW Version in System: ${RED}$Docker_Ver"
fi
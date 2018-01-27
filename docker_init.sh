#!/usr/bin/env bash

#Composed by Yauheni Pauliukanets ypauliukanets@edmunds.com
#To make fast Docker container start with the latest image version.

#Color Constants
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

#This is part of the script gw_ver.sh
echo -e "${YELLOW}Requesting last GW Images Version from Kingpin..${NC}"
GW_LAST_IMAGE=`curl -s http://kingpin/api/docker/environment/qa-21/artifact/groundwork-web | python -c "import sys, json; print json.load(sys.stdin)[0]['image']"`
echo -e "${GREEN}Image detected as: ${RED}$GW_LAST_IMAGE"
gw_ver=`echo $GW_LAST_IMAGE | egrep -o '[[:digit:]].[[:digit:]].[[:digit:]]{3}$'`
echo -e "${GREEN}Last Version is: ${RED}$gw_ver"

#Check if docker's service is running
if (( $(ps -ef | grep -v grep | grep docker | wc -l) > 0 ))
then
    docker_ver=`docker images | grep groundwork | awk '{ print $2 }' | head -n 1`
    echo -e "${YELLOW}Current GW Version in System: ${RED}$docker_ver"
fi

if [[ $docker_ver < $gw_ver ]]
then
    echo -e "${PURPLE}Your current Docker version is outdated!"
    ALL_CONTAINERS=`docker ps -aq`
    echo -e "${YELLOW}Stopping all containers..${NC}"
    docker stop $ALL_CONTAINERS
    echo -e "${YELLOW}Removing all containers..${NC}"
    docker rm $ALL_CONTAINERS
    #Remove all images
    #docker rmi $(docker images -q)
else
    echo -e "${PURPLE}Your current Docker version is still actual!"
fi

subversion=`echo $gw_ver | egrep -o '[[:digit:]]{3}$'`
CONTAINER_NAME=gw-$subversion
echo -e "${GREEN}Container Name will be: ${RED}$CONTAINER_NAME"
GW_EAST_EMAGE=`sed "s/west-2/east-1/g" <<< $GW_LAST_IMAGE`
echo -e "${YELLOW}Starting docker with east image: ${RED}$GW_EAST_EMAGE ${NC}"

sudo $(aws ecr get-login --region us-east-1 --no-include-email)
sudo docker run -p 8080:8080 --name $CONTAINER_NAME --hostname local.edmunds.com -v ~/git/cms-edmunds-prod/edmunds:/content/cms/edmunds -v ~/git/sites-groundwork/scaffold/groundwork:/content/cms/groundwork -v /deployments/edmunds/properties/common:/deployments/edmunds/properties/common -it $GW_EAST_EMAGE

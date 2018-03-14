#!/bin/sh

#Composed by ypauliukanets@edmunds.com
#To get list of artifacts from kingpin
#And provide Tomcat/Docker recent images 

#NOTE: `curl` and `python` should be installed

#Color Constants
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

ART_URL='http://kingpin/api/environments/qa-21/artifacts?_dc=1517238041229&page=1&start=0&limit=25&group=%5B%7B%22property%22%3A%22product%22%2C%22direction%22%3A%22ASC%22%7D%5D&sort=%5B%7B%22property%22%3A%22product%22%2C%22direction%22%3A%22ASC%22%7D%2C%7B%22property%22%3A%22artifactId%22%2C%22direction%22%3A%22ASC%22%7D%5D'

#http://nexus.prod-admin11.vip.aws1/nexus/service/local/artifact/maven/redirect?r=edmunds-release&g=com.edmunds.sites&a=dealerlocator-web&v=1.30.87&e=war
NEXUS_LINK='http://nexus.prod-admin11.vip.aws1/nexus/service/local/artifact/maven/redirect?r=edmunds-release&g=com.edmunds.sites&a='

ARRAY=('dealerlocator-web' 'vehicleresearch-web' 'vehiclelanding-web' 'review-rating-web' 'incentive-web' 'groundwork-web' 'photoflipper-web' 'common-rest-web' 'inventory-web')
ART_IN=`curl $ART_URL`

#ART_ARRAY=`curl $ART_URL | python -c "import sys, json; print json.load(sys.stdin)[0]['build']['repositoryPath']"`
ART_ARRAY=`cat <<< $ART_IN | python -c "import sys, json; print (json.load(sys.stdin))"`
ART_COUNT=`cat <<< $ART_IN | python -c "import sys, json; print (len(json.load(sys.stdin)))"`
((ART_COUNT--))

INDEX=0
ART_ARRAY_FOUND=()
ART_VER_ARRAY=()

#echo -e "Array of artifacts: "$ART_ARRAY
echo -e "\n${GREEN}Total Artifacts count: ${RED}"$ART_COUNT

#for n in { 0..$ART_COUNT } 
printf "${YELLOW}Pos Artifact Version Link2Download\n"
printf "${NC}-----------------------------------\n"

for (( n=0; n<=$ART_COUNT; n++ )) 
	do 
		ART=`cat <<< $ART_IN | python -c "import sys, json; print (json.load(sys.stdin)[$n])"`
		#echo -e "${RED}$n${GREEN}. "$ART
		
		for a in ${ARRAY[@]} 
			do
				if [[ $ART == *$a* ]] 
				then
					((INDEX++))
					#echo -e "${CYAN}Artifact $a found! Position: $n"
					REPO_PATH=`cat <<< $ART_IN | python -c "import sys, json; print (json.load(sys.stdin)[$n]['build']['repositoryPath'])"`
					#echo -e "${RED}Repository Path: ${GREEN}$REPO_PATH"
					ART_VER=`echo $REPO_PATH | egrep -o $a'-(.)*.war$'`
					ART_VER=`echo $ART_VER | egrep -o '[[:digit:]]+.[[:digit:]]+.[[:digit:]]+'`
					#echo -e "${RED}Latest version: ${GREEN}$ART_VER"
					LINK="$NEXUS_LINK$a&v=$ART_VER&e=war"
					#printf "${NC}$INDEX. ${GREEN}%4d %4s %4s \n" $n $a $ART_VER
					printf "${NC}$INDEX. ${GREEN}$a $ART_VER\n"
					printf "${GREEN}Tomcat War Link: ${CYAN}$LINK\n"
					DOCKER_IMG='699349871153.dkr.ecr.us-east-1.amazonaws.com/'$a':'$ART_VER
					printf "${GREEN}Docker Image: ${CYAN}$DOCKER_IMG\n"
					printf "${NC}-------------------------------\n"
					ART_ARRAY_FOUND+=($a)
					ART_VER_ARRAY+=($ART_VER)
				fi
			done
	done
	
	
echo -e "${CYAN}Do you want to run some image?"
read -p "Enter the number (0 - Cancel) <1,2,..> " prompt

docker_run(){
	GW_EAST_EMAGE="699349871153.dkr.ecr.us-east-1.amazonaws.com/$1:$2"
	
	echo -e "${GREEN}Full image name: ${RED}"$GW_EAST_EMAGE
	
	echo -e "${PURPLE}Start docker login...${NC}"
	sudo $(aws ecr get-login --region us-east-1 --no-include-email)
	
	echo -e "${PURPLE}Running docker container..."

	MINOR_VER=`echo "$2" | egrep -o '[[:digit:]]+$'`
	ART=$1
	CONTAINER_NAME="${ART:0:3}-$MINOR_VER"

	#check if this container is already exists
	##line number with TAG version
	TAG=$2
	#LINETAG=`docker images | awk '{if ($2 == "$TAG") print NR fi}'`
	#docker images | awk '$1~/common-rest-web/{ print NR }'
	#LINEREPO=`docker images | grep "$1" | awk '{ if ($2 == "$TAG") print NR }'`
	#LINEREPO=`docker images | grep "$1" | awk -v mytag="$TAG" '$2~/mytag/{ print NR }'`
	LINEREPO=`docker images | grep "$1" | awk -v mytag="$TAG" '$2==mytag {print NR}'`
	
    if [[ $LINEREPO -gt 0 ]]
        then
            echo -e "${GREEN}We've already found existent container in system: ${RED}$CONTAINER_NAME${NC}"
            sudo docker start -ai $CONTAINER_NAME
        else
            echo -e "${GREEN}Container name will be: ${RED}$CONTAINER_NAME"
            echo -e "${PURPLE}Next time can be started as: ${CYAN}sudo docker start -ai $CONTAINER_NAME"
            #SIMLINKS=-v ~/git/cms-edmunds-prod/edmunds:/content/cms/edmunds -v ~/git/sites-groundwork/scaffold/groundwork:/content/cms/groundwork -v /deployments/edmunds/properties/common:/deployments/edmunds/properties/common
	        sudo docker run -p 8080:8080 --name $CONTAINER_NAME --hostname local.edmunds.com -v ~/git/cms-edmunds-prod/edmunds:/content/cms/edmunds -v ~/git/sites-groundwork/scaffold/groundwork:/content/cms/groundwork -v /deployments/edmunds/properties/common:/deployments/edmunds/properties/common -it $GW_EAST_EMAGE
    fi

    if [[ $1 -ne "groundwork" ]] ;then
        echo -e "-----------------------------------"
        echo -e "${YELLOW}NOTE: Don't forget to update your hosts file for qa-2 server IP for Legacy App-s with:"
        #ImageId=`docker images | grep $2 | awk '{print $3}'`
        QA21IP=`nslookup qa-21-www.edmunds.com | grep Address | tail -n 1 | awk '{print $2}'`
        echo -e "${GREEN}$QA21IP   qa-2-www.edmunds.com${NC}"
        echo -e "-----------------------------------"
    fi
}

if (( prompt > 0 )) 
	then
	echo -e "${YELLOW}Option ${RED}$prompt ${YELLOW}choosen..."
	((prompt--))
	ART="${ART_ARRAY_FOUND[${prompt}]}"
	ART_VER="${ART_VER_ARRAY[${prompt}]}"
	echo -e "${GREEN}Artifact choosen: ${RED}$ART"
	echo -e "${GREEN}Artifact version: ${RED}$ART_VER"
	
		#Check if docker's service is running
		if (( $(ps -ef | grep -v grep | grep docker | wc -l) > 0 ))
		then
			docker_run $ART $ART_VER
		fi
fi

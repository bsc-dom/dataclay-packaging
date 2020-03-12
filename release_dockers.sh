#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
grn=$'\e[1;32m'
blu=$'\e[1;34m'
red=$'\e[1;91m'
end=$'\e[0m'
set -e
################################## FUNCTIONS #############################################
function check_docker_buildx_version { 
	printf "Checking if docker buildx is available..."
	docker buildx version 2>&1 > /dev/null
	if [ $? -ne 0 ]; then return $?; fi
	printf "OK\n"
}

function prepare_docker_builder { 
	return -1
	docker buildx use dataclaybuilder
	if [ $? -ne 0 ]; then
		printf "ERROR\n" 
		echo "Please, create a new builder named dataclaybuilder i.e. docker buildx create --name dataclaybuilder"
		return -1
	fi 
	printf "OK\n"
	echo "Checking buildx dataclaybuilder with available platforms to simulate..."
	
	BUILDER_PLATFORMS=$(docker buildx inspect --bootstrap | grep Platforms | awk -F":" '{print $2}')
	IFS=',' read -ra BUILDER_PLATFORMS_ARRAY <<< "$BUILDER_PLATFORMS"
	IFS=',' read -ra SUPPORTED_PLATFORMS_ARRAY <<< "$PLATFORMS"
	echo "Dataclaybuilder created with platforms: ${BUILDER_PLATFORMS_ARRAY[@]}"	
	
	#Print the split string
	for i in "${SUPPORTED_PLATFORMS_ARRAY[@]}"
	do
		FOUND=false
		SUP_PLATFORM=`echo $i | sed 's/ *$//g'` #remove spaces
		printf "Checking if platform $i can be simulated by buildx..."
	    for j in "${BUILDER_PLATFORMS_ARRAY[@]}"
	    do
	    	B_PLATFORM=`echo $j | sed 's/ *$//g'` #remove spaces
			if [ "$SUP_PLATFORM" == "$B_PLATFORM" ]; then
				FOUND=true
				break
			fi
		done
		if [ "$FOUND" = false ] ; then
			echo "ERROR: missing support for $i in buildx builder."
			echo " Check https://github.com/multiarch/qemu-user-static for more information on how to simulate architectures"
			return -1
		fi
		printf "OK\n"
		
	done
	
}

function get_container_version { 
	if [ $# -gt 0 ]; then 
		EE_VERSION=$1 # i.e. can be python py3.6 or jdk8
		DATACLAY_EE_VERSION="${EE_VERSION//./}"
		if [ "$DEV" = true ] ; then
			DATACLAY_CONTAINER_VERSION="${DATACLAY_RELEASE_VERSION}.${DATACLAY_EE_VERSION}.${GIT_BRANCH}"
		else 
			DATACLAY_CONTAINER_VERSION="$DATACLAY_RELEASE_VERSION.${DATACLAY_EE_VERSION}"
		fi 
	else 
		if [ "$DEV" = true ] ; then
			DATACLAY_CONTAINER_VERSION="${DATACLAY_RELEASE_VERSION}.${GIT_BRANCH}"
		else 
			DATACLAY_CONTAINER_VERSION="$DATACLAY_RELEASE_VERSION"
	fi 
	fi
	echo ${DATACLAY_CONTAINER_VERSION}
}

pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}


function printMsg { 
  echo "${blu}[dataClay release] $1 ${end}"
}
function printError { 
  echo "${red}======== $1 ========${end}"
}

################################## OPTIONS #############################################

DEV=false
# idiomatic parameter and option handling in sh
while test $# -gt 0
do
    case "$1" in
        --dev) DEV=true
            ;;
        --*) echo "bad option $1"
        	exit -1
            ;;
        *) echo "bad option $1"
        	exit -1
            ;;
    esac
    shift
done

################################## PLATFORMS #############################################
SUPPORTED_JAVA_VERSIONS=(8 11)
SUPPORTED_PYTHON_VERSIONS=(3.6 3.7)
PLATFORMS=linux/amd64,linux/arm/v7
DEFAULT_JAVA=11
DEFAULT_PYTHON=3.7

################################## VERSIONING #############################################
DATACLAY_RELEASE_VERSION=$(cat $SCRIPTDIR/VERSION.txt)
GIT_BRANCH=$(git name-rev --name-only HEAD)
DEFAULT_TAG="$(get_container_version)"
DEFAULT_JDK_TAG="$(get_container_version jdk$DEFAULT_JAVA)"
DEFAULT_PY_TAG="$(get_container_version py$DEFAULT_PYTHON)"
BASE_VERSION_TAG="$(get_container_version)"
CLIENT_TAG="$(get_container_version)"
# get version from pom.xml 
JAR_VERSION=$(grep version $SCRIPTDIR/logicmodule/javaclay/pom.xml | grep -v -e '<?xml|~'| head -n 1 | sed 's/[[:space:]]//g' | sed -E 's/<.{0,1}version>//g' | awk '{print $1}')
JAR_NAME=dataclay-${JAR_VERSION}-jar-with-dependencies.jar
################################## MAIN #############################################


printMsg "'"'
      _       _         _____ _             
     | |     | |       / ____| |            
   __| | __ _| |_ __ _| |    | | __ _ _   _ 
  / _` |/ _` | __/ _` | |    | |/ _` | | | |
 | (_| | (_| | || (_| | |____| | (_| | |_| |  release script
  \__,_|\__,_|\__\__,_|\_____|_|\__,_|\__, |
                                       __/ |
                                      |___/ 
'"'"
printMsg " Welcome to dataClay release script!"
echo " -- I'm going to push into DockerHub docker images: "
echo "                bscdataclay/base:${BASE_VERSION_TAG}"
echo "                bscdataclay/logicmodule:${DEFAULT_TAG}"
echo "                bscdataclay/dsjava:${DEFAULT_TAG}"
echo "                bscdataclay/dspython:${DEFAULT_TAG}"
echo "                bscdataclay/client:${CLIENT_TAG}"
for JAVA_VERSION in ${SUPPORTED_JAVA_VERSIONS[@]}; do
	DATACLAY_DOCKER_TAG="$(get_container_version jdk$JAVA_VERSION)"
	echo "                bscdataclay/logicmodule:${DATACLAY_DOCKER_TAG}"
	echo "                bscdataclay/dsjava:${DATACLAY_DOCKER_TAG}"
done
for PYTHON_VERSION in ${SUPPORTED_PYTHON_VERSIONS[@]}; do
	DATACLAY_DOCKER_TAG="$(get_container_version py$PYTHON_VERSION)"
	echo "                bscdataclay/dspython:${DATACLAY_DOCKER_TAG}"
done

################################## DEV RELEASE #############################################
if [ "$DEV" = true ] ; then
	$SCRIPTDIR/build.sh --dev
	docker push bscdataclay/base:${BASE_VERSION_TAG}
	for JAVA_VERSION in ${SUPPORTED_JAVA_VERSIONS[@]}; do
		DATACLAY_DOCKER_TAG="$(get_container_version jdk$JAVA_VERSION)"
		docker push bscdataclay/logicmodule:${DATACLAY_DOCKER_TAG}
		docker push bscdataclay/dsjava:${DATACLAY_DOCKER_TAG}
	done
	for PYTHON_VERSION in ${SUPPORTED_PYTHON_VERSIONS[@]}; do
		DATACLAY_DOCKER_TAG="$(get_container_version py$PYTHON_VERSION)"
		docker push bscdataclay/dspython:${DATACLAY_DOCKER_TAG}
	done
	docker push bscdataclay/logicmodule:${DEFAULT_TAG}
	docker push bscdataclay/dsjava:${DEFAULT_TAG}
	docker push bscdataclay/dsjava:${DEFAULT_TAG}
	docker push bscdataclay/dspython:${DEFAULT_TAG}
	docker push bscdataclay/client:${CLIENT_TAG}
fi
###############################################################################

printMsg " Checking requirements ... "
$SCRIPTDIR/check_requirements.sh
prepare_docker_builder
printMsg " Requirements accomplished :) "

################################## VERSIONS #############################################
#
#
	
	read -p "Enter dataClay version [$DATACLAY_RELEASE_VERSION]: " dataclay_version
	DATACLAY_RELEASE_VERSION=${dataclay_version:-$DATACLAY_RELEASE_VERSION}
	
	
	while true; do
		version=`grep -m 1 "<version>" $SCRIPTDIR/logicmodule/javaclay/pom.xml`
		echo "Current defined version in pom.xml: $grn $version $end" 
		read -p "Are you sure pom.xml version is correct (yes/no)? " yn
		case $yn in
			[Yy]* ) break;;
			[Nn]* ) echo "Modify it and try again."; exit;;
			* ) echo "$red Please answer yes or no. $end";;
		esac
	done 
	
	
	while true; do
		version=`grep -m 1 "version" $SCRIPTDIR/dspython/pyclay/setup.py`
		echo "Current defined version in setup.py: $grn $version $end" 
		read -p "Are you sure setup.py version is correct (yes/no)? " yn
		case $yn in
			[Yy]* ) break;;
			[Nn]* ) echo "Modify it and try again."; exit;;
			* ) echo "$red Please answer yes or no. $end";;
		esac
	done
	
	while true; do
		echo "Default Java version will be: $DEFAULT_JAVA $version $end" 
		read -p "Are you sure is correct (yes/no)? " yn
		case $yn in
			[Yy]* ) break;;
			[Nn]* ) echo "Modify it and try again."; exit;;
			* ) echo "$red Please answer yes or no. $end";;
		esac
	done 
	
	while true; do
		echo "Default Python version will be: $DEFAULT_PYTHON $version $end" 
		read -p "Are you sure is correct (yes/no)? " yn
		case $yn in
			[Yy]* ) break;;
			[Nn]* ) echo "Modify it and try again."; exit;;
			* ) echo "$red Please answer yes or no. $end";;
		esac
	done 


declare -a DOCKER_IMAGES_PUSHED
  
################################## PUSH #############################################


# CREATE DATACLAY JAR : IF IT EXISTS WHAT TO DO?
pushd $SCRIPTDIR/logicmodule/javaclay
mvn package -DskipTests=true
popd

# BASE IMAGES 
pushd $SCRIPTDIR/base
echo "************* Pushing image named bscdataclay/base:$BASE_VERSION_TAG *************"
docker buildx build -t bscdataclay/base:$BASE_VERSION_TAG --platform $PLATFORMS --push .
DOCKER_IMAGES_PUSHED+=(bscdataclay/base:$BASE_VERSION_TAG)
echo "************* bscdataclay/base:$BASE_VERSION_TAG IMAGE PUSHED! *************" 
popd

# LOGICMODULE
pushd $SCRIPTDIR/logicmodule
for JAVA_VERSION in ${SUPPORTED_JAVA_VERSIONS[@]}; do
	VERSION="$(get_container_version jdk$JAVA_VERSION)"
	echo "************* Pushing image named bscdataclay/logicmodule:$VERSION *************"
	docker buildx build --build-arg JDK=$JAVA_VERSION --build-arg BASE_VERSION=$BASE_VERSION_TAG --build-arg LOCAL_JAR=$JAR_NAME -t bscdataclay/logicmodule:$VERSION --platform $PLATFORMS --push .
	DOCKER_IMAGES_PUSHED+=(bscdataclay/logicmodule:$VERSION)
	echo "************* bscdataclay/logicmodule:$VERSION IMAGE PUSHED! *************"
done
popd 

# DSJAVA
pushd $SCRIPTDIR/dsjava
for JAVA_VERSION in ${SUPPORTED_JAVA_VERSIONS[@]}; do
	VERSION="$(get_container_version jdk$JAVA_VERSION)"
	echo "************* Building image named bscdataclay/dsjava:$VERSION *************"
	docker buildx build --build-arg LOGICMODULE_VERSION=$VERSION -t bscdataclay/dsjava:$VERSION --platform $PLATFORMS --push .
	DOCKER_IMAGES_PUSHED+=(bscdataclay/dsjava:$VERSION)
	echo "************* bscdataclay/dsjava:$VERSION DONE! *************"
done
popd 

# DSPYTHON
pushd $SCRIPTDIR/dspython
for PYTHON_VERSION in ${SUPPORTED_PYTHON_VERSIONS[@]}; do
	VERSION="$(get_container_version py$PYTHON_VERSION)"
	# Get python version without subversion to install it in some packages
	PYTHON_PIP_VERSION=$PYTHON_VERSION
	PYTHON_PIP_VERSION=$(echo $PYTHON_VERSION | awk -F '.' '{print $1}')
	echo "************* Building image named bscdataclay/dspython:$VERSION python version $PYTHON_VERSION and pip version $PYTHON_PIP_VERSION *************"
	docker buildx build --build-arg BASE_VERSION=$BASE_VERSION_TAG \
				 --build-arg DATACLAY_PYVER=$PYTHON_VERSION \
				 --build-arg PYTHON_PIP_VERSION=$PYTHON_PIP_VERSION -t bscdataclay/dspython:$VERSION --platform $PLATFORMS --push .
	DOCKER_IMAGES_PUSHED+=(bscdataclay/dspython:$VERSION)
	echo "************* bscdataclay/dspython:$VERSION DONE! *************"
done
popd 

# CLIENT 
pushd $SCRIPTDIR/client
# client will not have execution environemnt in version, like pypi
echo "************* Building image named bscdataclay/client:$CLIENT_TAG *************"
docker buildx build --build-arg DATACLAY_DSPYTHON_DOCKER_TAG=$PYCLAY_TAG \
			 --build-arg DATACLAY_LOGICMODULE_DOCKER_TAG=$JAVACLAY_TAG \
			 --build-arg DATACLAY_PYVER=$DEFAULT_PYTHON \
			 -t bscdataclay/client:$CLIENT_TAG --platform $PLATFORMS --push .
DOCKER_IMAGES_PUSHED+=(bscdataclay/client:$CLIENT_TAG) 
echo "************* bscdataclay/client:$CLIENT_TAG DONE! *************"
popd 


## Tag default versions 

docker buildx imagetools create --tag bscdataclay/logicmodule:$DEFAULT_TAG bscdataclay/logicmodule:$DEFAULT_JDK_TAG
DOCKER_IMAGES_PUSHED+=(bscdataclay/logicmodule:$DEFAULT_TAG) 

docker buildx imagetools create --tag bscdataclay/dsjava:$DEFAULT_TAG bscdataclay/dsjava:$DEFAULT_JDK_TAG
DOCKER_IMAGES_PUSHED+=(bscdataclay/dsjava:$DEFAULT_TAG) 

docker buildx imagetools create --tag bscdataclay/dspython:$DEFAULT_TAG bscdataclay/dspython:$DEFAULT_PY_TAG
DOCKER_IMAGES_PUSHED+=(bscdataclay/dspython:$DEFAULT_TAG) 

##### TAG LATEST #####
docker buildx imagetools create --tag bscdataclay/base bscdataclay/base:$DEFAULT_TAG
DOCKER_IMAGES_PUSHED+=(bscdataclay/base) 
	
docker buildx imagetools create --tag bscdataclay/logicmodule bscdataclay/logicmodule:$DEFAULT_TAG
DOCKER_IMAGES_PUSHED+=(bscdataclay/logicmodule) 
	
docker buildx imagetools create --tag bscdataclay/dsjava bscdataclay/dsjava:$DEFAULT_TAG
DOCKER_IMAGES_PUSHED+=(bscdataclay/dsjava) 
	
docker buildx imagetools create --tag bscdataclay/dspython bscdataclay/dspython:$DEFAULT_TAG
DOCKER_IMAGES_PUSHED+=(bscdataclay/dspython) 
	
docker buildx imagetools create --tag bscdataclay/client bscdataclay/client:$DEFAULT_TAG
DOCKER_IMAGES_PUSHED+=(bscdataclay/client) 

printMsg " ===== Done! ====="
printMsg " Push summary  "
echo "DOCKER images PUSHED: " 
for DOCKER_IMAGE in ${DOCKER_IMAGES_PUSHED[@]}; do
	echo "$DOCKER_IMAGE platforms"	
	docker buildx imagetools inspect $DOCKER_IMAGE | grep Platform
done



#!/bin/bash
#===================================================================================
#
# FILE: docker_deploy.sh
#
# USAGE: docker_deploy.sh [--dev] 
#
# DESCRIPTION: Deploy dataClay dockers into DockerHub
#
# OPTIONS: see function ’usage’ below
# REQUIREMENTS: ---
# BUGS: ---
# NOTES: ---
# AUTHOR: dgasull@bsc.es
# COMPANY: Barcelona Supercomputing Center (BSC)
# VERSION: 1.0
#===================================================================================
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
grn=$'\e[1;32m'; blu=$'\e[1;34m'; red=$'\e[1;91m'; end=$'\e[0m';
function printMsg { echo "${blu}[$(basename $0)] $1 ${end}"; }
function printError { echo "${red}======== $1 ========${end}"; }

#=== FUNCTION ================================================================
# NAME: check_docker_buildx_version
# DESCRIPTION: Check that docker buildx is available
#=============================================================================
function check_docker_buildx_version { 
	printf "Checking if docker buildx is available..."
	docker buildx version 2>&1 > /dev/null
	if [ $? -ne 0 ]; then return $?; fi
	printf "OK\n"
}

#=== FUNCTION ================================================================
# NAME: prepare_docker_builder
# DESCRIPTION: Prepare docker buildx to support required platforms
#=============================================================================
function prepare_docker_builder { 

	# prepare architectures
	docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
	
	DOCKER_BUILDER=$(docker buildx create) 
	docker buildx use $DOCKER_BUILDER
	
	echo "Checking buildx with available platforms to simulate..."
	BUILDER_PLATFORMS=$(docker buildx inspect --bootstrap | grep Platforms | awk -F":" '{print $2}')
	IFS=',' read -ra BUILDER_PLATFORMS_ARRAY <<< "$BUILDER_PLATFORMS"
	IFS=',' read -ra SUPPORTED_PLATFORMS_ARRAY <<< "$PLATFORMS"
	echo "Builder created with platforms: ${BUILDER_PLATFORMS_ARRAY[@]}"	
	
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
#=== FUNCTION ================================================================
# NAME: pushd
# DESCRIPTION: Override pushd to be less verbose
#=============================================================================
pushd () {
    command pushd "$@" > /dev/null
}

#=== FUNCTION ================================================================
# NAME: popd
# DESCRIPTION: Override popd to be less verbose
#=============================================================================
popd () {
    command popd "$@" > /dev/null
}

DEV=false
DONOTPROMPT=false
# idiomatic parameter and option handling in sh
while test $# -gt 0
do
    case "$1" in
        --dev) 
        	export DEV=true
            ;;
        -y) 
        	DONOTPROMPT=true 
        	;;
        --*) 
        	echo "bad option $1"
        	exit -1
            ;;
        *) 
        	echo "bad option $1"
        	exit -1
            ;;
    esac
    shift
done

if [ "$DEV" = false ] ; then
	GIT_BRANCH=$(git name-rev --name-only HEAD)
	if [[ "$GIT_BRANCH" != "master" ]]; then
	  echo 'Aborting deployment, only master branch can deploy a release. Use --dev instead.';
	  exit 1;
	fi
fi

################################## MAIN #############################################


printMsg "'"'
      _       _         _____ _             
     | |     | |       / ____| |            
   __| | __ _| |_ __ _| |    | | __ _ _   _ 
  / _` |/ _` | __/ _` | |    | |/ _` | | | |
 | (_| | (_| | || (_| | |____| | (_| | |_| |  deploy script
  \__,_|\__,_|\__\__,_|\_____|_|\__,_|\__, |
                                       __/ |
                                      |___/ 
'"'"
printMsg " Welcome to dataClay release script!"
REPOSITORY="bscdataclay"
source $SCRIPTDIR/config.sh

DOCKERX_CACHE=$SCRIPTDIR/.dockerbuildx
EXTRA_ARGS=""
if [ -f $DOCKERX_CACHE/index.json ]; then 
	echo " -- Found index cache at $DOCKERX_CACHE"
	EXTRA_ARGS="--cache-from=type=local,src=$DOCKERX_CACHE" 
fi

if [ $DONOTPROMPT == false ]; then
	while true; do
		read -p "Is everything correct (y/n)? " yn
		case $yn in
			[Yy]* ) break;;
			[Nn]* ) echo "Modify it and try again."; exit;;
			* ) echo "$red Please answer yes or no. $end";;
		esac
	done 
fi
###############################################################################
prepare_docker_builder
declare -a DOCKER_IMAGES_PUSHED
################################## PUSH #############################################
set -e #Exit if some command fails


# CREATE DATACLAY JAR : IF IT EXISTS WHAT TO DO?
pushd $SCRIPTDIR/logicmodule/javaclay
mvn package -DskipTests=true >/dev/null
popd

# BASE IMAGES 
pushd $SCRIPTDIR/base
echo "************* Pushing image named $REPOSITORY/base:$BASE_VERSION_TAG *************"
docker buildx build -t $REPOSITORY/base:$BASE_VERSION_TAG \
	--platform $PLATFORMS \
	--cache-to=type=local,dest=$DOCKERX_CACHE $EXTRA_ARGS \
	--push .
DOCKER_IMAGES_PUSHED+=($REPOSITORY/base:$BASE_VERSION_TAG)
echo "************* $REPOSITORY/base:$BASE_VERSION_TAG IMAGE PUSHED! *************" 
popd

# LOGICMODULE
pushd $SCRIPTDIR/logicmodule
for JAVA_VERSION in ${!JAVA_CONTAINER_VERSIONS[@]}; do
	VERSION="${JAVA_CONTAINER_VERSIONS[$JAVA_VERSION]}"
	echo "************* Pushing image named $REPOSITORY/logicmodule:$VERSION *************"
	docker buildx build -t $REPOSITORY/logicmodule:$VERSION \
		--build-arg JDK=$JAVA_VERSION \
		--build-arg BASE_VERSION=$BASE_VERSION_TAG \
		--build-arg LOCAL_JAR=$JAR_NAME \
		--platform $PLATFORMS \
		--cache-to=type=local,dest=$DOCKERX_CACHE $EXTRA_ARGS \
		--push .
	DOCKER_IMAGES_PUSHED+=($REPOSITORY/logicmodule:$VERSION)
	echo "************* $REPOSITORY/logicmodule:$VERSION IMAGE PUSHED! *************"
done
popd 

# DSJAVA
pushd $SCRIPTDIR/dsjava
for JAVA_VERSION in ${!JAVA_CONTAINER_VERSIONS[@]}; do
	VERSION="${JAVA_CONTAINER_VERSIONS[$JAVA_VERSION]}"
	echo "************* Building image named $REPOSITORY/dsjava:$VERSION *************"
	docker buildx build -t $REPOSITORY/dsjava:$VERSION \
		--build-arg LOGICMODULE_VERSION=$VERSION \
		--platform $PLATFORMS \
		--cache-to=type=local,dest=$DOCKERX_CACHE $EXTRA_ARGS \
		--push .
	DOCKER_IMAGES_PUSHED+=($REPOSITORY/dsjava:$VERSION)
	echo "************* $REPOSITORY/dsjava:$VERSION DONE! *************"
done
popd 

# DSPYTHON
pushd $SCRIPTDIR/dspython
for PYTHON_VERSION in ${!PYTHON_CONTAINER_VERSIONS[@]}; do
	VERSION="${PYTHON_CONTAINER_VERSIONS[$PYTHON_VERSION]}"
	# Get python version without subversion to install it in some packages
	PYTHON_PIP_VERSION=$PYTHON_VERSION
	PYTHON_PIP_VERSION=$(echo $PYTHON_VERSION | awk -F '.' '{print $1}')
	echo "************* Building image named $REPOSITORY/dspython:$VERSION python version $PYTHON_VERSION and pip version $PYTHON_PIP_VERSION *************"
	docker buildx build -t $REPOSITORY/dspython:$VERSION \
		--build-arg BASE_VERSION=$BASE_VERSION_TAG \
		--build-arg DATACLAY_PYVER=$PYTHON_VERSION \
		--build-arg PYTHON_PIP_VERSION=$PYTHON_PIP_VERSION \
		--platform $PLATFORMS \
		--cache-to=type=local,dest=$DOCKERX_CACHE $EXTRA_ARGS \
		--push .
	DOCKER_IMAGES_PUSHED+=($REPOSITORY/dspython:$VERSION)
	echo "************* $REPOSITORY/dspython:$VERSION DONE! *************"
done
popd 

# CLIENT 
pushd $SCRIPTDIR/client
# client will not have execution environemnt in version, like pypi
echo "************* Building image named $REPOSITORY/client:$CLIENT_TAG *************"
docker buildx build -t $REPOSITORY/client:$CLIENT_TAG \
	--build-arg DATACLAY_DSPYTHON_DOCKER_TAG=$PYCLAY_TAG \
	--build-arg DATACLAY_LOGICMODULE_DOCKER_TAG=$JAVACLAY_TAG \
	--build-arg DATACLAY_PYVER=$DEFAULT_PYTHON \
	--platform $PLATFORMS \
	--cache-to=type=local,dest=$DOCKERX_CACHE $EXTRA_ARGS \
	--push .
DOCKER_IMAGES_PUSHED+=($REPOSITORY/client:$CLIENT_TAG) 
echo "************* $REPOSITORY/client:$CLIENT_TAG DONE! *************"
popd 


## Tag default versions 

docker buildx imagetools create --tag $REPOSITORY/logicmodule:$DEFAULT_TAG $REPOSITORY/logicmodule:$DEFAULT_JDK_TAG
DOCKER_IMAGES_PUSHED+=($REPOSITORY/logicmodule:$DEFAULT_TAG) 

docker buildx imagetools create --tag $REPOSITORY/dsjava:$DEFAULT_TAG $REPOSITORY/dsjava:$DEFAULT_JDK_TAG
DOCKER_IMAGES_PUSHED+=($REPOSITORY/dsjava:$DEFAULT_TAG) 

docker buildx imagetools create --tag $REPOSITORY/dspython:$DEFAULT_TAG $REPOSITORY/dspython:$DEFAULT_PY_TAG
DOCKER_IMAGES_PUSHED+=($REPOSITORY/dspython:$DEFAULT_TAG) 

##### TAG LATEST #####
if [ "$DEV" = false ] ; then
	docker buildx imagetools create --tag $REPOSITORY/base $REPOSITORY/base:$DEFAULT_TAG
	DOCKER_IMAGES_PUSHED+=($REPOSITORY/base) 
		
	docker buildx imagetools create --tag $REPOSITORY/logicmodule $REPOSITORY/logicmodule:$DEFAULT_TAG
	DOCKER_IMAGES_PUSHED+=($REPOSITORY/logicmodule) 
		
	docker buildx imagetools create --tag $REPOSITORY/dsjava $REPOSITORY/dsjava:$DEFAULT_TAG
	DOCKER_IMAGES_PUSHED+=($REPOSITORY/dsjava) 
		
	docker buildx imagetools create --tag $REPOSITORY/dspython $REPOSITORY/dspython:$DEFAULT_TAG
	DOCKER_IMAGES_PUSHED+=($REPOSITORY/dspython) 
		
	docker buildx imagetools create --tag $REPOSITORY/client $REPOSITORY/client:$DEFAULT_TAG
	DOCKER_IMAGES_PUSHED+=($REPOSITORY/client) 
fi

printMsg " Push summary  "
echo "DOCKER images PUSHED: " 
for DOCKER_IMAGE in ${DOCKER_IMAGES_PUSHED[@]}; do
	echo "$DOCKER_IMAGE platforms"	
	docker buildx imagetools inspect $DOCKER_IMAGE | grep Platform
done

# Remove builder
docker buildx rm $DOCKER_BUILDER
printMsg " ===== Done! ====="




#!/bin/bash
#===================================================================================
#
# FILE: config.sh
#
# USAGE: stale-config.sh
#
# DESCRIPTION: -
# accomplished and prepare versions.
#
# OPTIONS: ---
# REQUIREMENTS: ---
# BUGS: ---
# NOTES: ---
# AUTHOR: dgasull@bsc.es
# COMPANY: Barcelona Supercomputing Center
# VERSION: 2.4
#===================================================================================
CONFIGDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
#=== FUNCTION ================================================================
# NAME: get_container_version
# DESCRIPTION: Get container version
# PARAMETER 1: Execution environment version i.e. can be python py3.6 or jdk8
#===============================================================================
function get_container_version { 
	if [ $# -gt 0 ]; then 
		EE_VERSION=$1 
		DATACLAY_EE_VERSION="${EE_VERSION//./}"
		if [ "$DEV" = true ] ; then
			DATACLAY_CONTAINER_VERSION="${DATACLAY_VERSION}.${DATACLAY_EE_VERSION}.dev"
		else 
			DATACLAY_CONTAINER_VERSION="$DATACLAY_VERSION.${DATACLAY_EE_VERSION}"
		fi 
	else 
		if [ "$DEV" = true ] ; then
			DATACLAY_CONTAINER_VERSION="${DATACLAY_VERSION}.dev"
		else 
			DATACLAY_CONTAINER_VERSION="$DATACLAY_VERSION"
		fi 
	fi
	echo ${DATACLAY_CONTAINER_VERSION}
}
#==============================================================================
grn=$'\e[1;32m'; blu=$'\e[1;34m'; red=$'\e[1;91m'; yellow=$'\e[1;33m'; end=$'\e[0m';
function printMsg { echo "${blu}[$(basename $0)] $1 ${end}"; }
function printWarn { echo "${yellow}[$(basename $0)] $1 ${end}"; }
function printError { echo "${red}======== $1 ========${end}"; }
#=== FUNCTION ================================================================
# NAME: deploy
# DESCRIPTION: Deploy to DockerHub and retry if connection fails
#=============================================================================
function build {
  if [ "$SHARE_BUILDER" = "false" ]; then
    if [ "$DOCKER_BUILDX_COMMAND" = "buildx" ]; then
        source $CONFIGDIR/prepare_docker_builder.sh
    fi
  fi
  SECONDS=0
  COMMAND=""
  while [[ $# -gt 0 ]]; do
    param="$1"
    case $param in
        -t)
        IMAGE="$2"
        COMMAND+="$1 $2 "
        shift # past argument
        shift # past value
        ;;
        *)    # unknown option
        COMMAND+="$1 "
        shift # past argument
        ;;
    esac
  done
  printMsg "************* Building image $IMAGE (retry $n) *************"
  printMsg "$COMMAND"
  eval "$COMMAND"
  printMsg "************* $IMAGE IMAGE BUILD! (in $n retries) *************"

  if [ ! -z $REGISTRY ] && [ $REGISTRY != "" ]; then
    echo "Pulling from local registry for platform $BUILD_PLATFORM"
    docker pull $BUILD_PLATFORM $IMAGE
    docker tag $IMAGE ${IMAGE/localhost:5000\//}
  fi

  echo "$(($SECONDS / 60)) minutes and $(($SECONDS % 60)) seconds elapsed."
}


#=== FUNCTION ================================================================
# NAME: deploy
# DESCRIPTION: Deploy to DockerHub and retry if connection fails
#=============================================================================
function deploy {
  if [ "$SHARE_BUILDER" = "false" ]; then
    source $CONFIGDIR/prepare_docker_builder.sh
  fi
  SECONDS=0
  COMMAND=""
  while [[ $# -gt 0 ]]; do
    param="$1"
    case $param in
        -t)
        IMAGE="$2"
        COMMAND+="$1 $2 "
        shift # past argument
        shift # past value
        ;;
        *)    # unknown option
        COMMAND+="$1 "
        shift # past argument
        ;;
    esac
  done
  export n=0
  until [ "$n" -ge 5 ] # Retry maximum 5 times
  do
    printMsg "************* Pushing image $IMAGE (retry $n) *************"
    printMsg "$COMMAND"
    eval "$COMMAND" && break
    n=$((n+1))
    sleep 15
  done
  if [ "$n" -eq 5 ]; then
    printError "ERROR: $IMAGE could not be pushed"
    return 1
  fi

  printMsg "************* $IMAGE IMAGE PUSHED! (in $n retries) *************"
  echo "$(($SECONDS / 60)) minutes and $(($SECONDS % 60)) seconds elapsed."
}
################################## OPTIONS ####################################
set -e
ORCHDIR=$CONFIGDIR/../orchestration/
DATACLAY_DOCKER_DIR=$CONFIGDIR/../docker/
export DEV=false
DONOTPROMPT=false
SHARE_BUILDER="false"
DOCKERFILE=""
TAG_SUFFIX=""
BRANCH_TO_CHECK="master"
DOCKER_PROGRESS=""
PLATFORMS_FILE=$CONFIGDIR/PLATFORMS.txt
DOCKER_COMMAND=""
DOCKER_BUILDX_COMMAND=""
BUILD_PLATFORM=""
ADD_DATE_TAG=false
export PACKAGE_JAR="true"
while test $# -gt 0
do
    case "$1" in
        --dev)
          export DEV=true
          BRANCH_TO_CHECK="develop"
            ;;
        --ee) 
        	shift 
        	EXECUTION_ENVIRONMENT=$1 
        	;;
        -y)
        	DONOTPROMPT=true
        	;;
        --add-date-tag)
          export ADD_DATE_TAG=true
          ;;
        --do-not-package)
        	export PACKAGE_JAR="false"
        	;;
        --share-builder)
          export SHARE_BUILDER="true"
          ;;
        --plaforms-file)
          shift
          PROVIDED_PLATFORMS_FILE=$1
          ;;
        --build-platform)
          shift
          PLATFORM_PROVIDED=$1
          if [ "$PLATFORM_PROVIDED" != "linux/amd64" ]; then
            echo "NOTE: Provided build platform $PLATFORM_PROVIDED: Using buildx"
            echo "WARNING: Make sure to have a local registry running: docker run -d -p 5000:5000 --restart=always --name dataclay_buildx_registry registry:2"
            echo "WARNING: Make sure to add "insecure-registries" : ["localhost:5000"] to /etc/docker/daemon.json and restart docker"
            REGISTRY="localhost:5000/"
            DOCKER_COMMAND="--push"
            DOCKER_BUILDX_COMMAND="buildx"
            BUILD_PLATFORM="--platform $PLATFORM_PROVIDED "
          fi
          ;;
        --slim) 
        	export DOCKERFILE="-f slim.Dockerfile" 
        	export TAG_SUFFIX="-slim"
        	PLATFORMS_FILE=$CONFIGDIR/SLIM_PLATFORMS.txt
        	;;
        --plain)
          export DOCKER_PROGRESS="--progress plain"
          ;;
        --alpine) 
        	export DOCKERFILE="-f alpine.Dockerfile" 
        	export TAG_SUFFIX="-alpine"
        	PLATFORMS_FILE=$CONFIGDIR/ALPINE_PLATFORMS.txt
        	;;
        --singularityimg)
          shift
        	SINGULARITY_IMG=$1
        	;;
        --normal)
          echo "Skipping option --normal"
          ;;
        *) echo "Bad option $1"
        	exit 1
            ;;
    esac
    shift
done
###############################################################################
if [ ! -z $PROVIDED_PLATFORMS_FILE ]; then
  source $PROVIDED_PLATFORMS_FILE
else
  source $PLATFORMS_FILE
fi

#GIT_BRANCH=$(git for-each-ref --format='%(objectname) %(refname:short)' refs/heads | awk "/^$(git rev-parse HEAD)/ {print \$2}")
#if [[ "$GIT_BRANCH" != "$BRANCH_TO_CHECK" ]]; then
#  printError "Branch is not $BRANCH_TO_CHECK. Found $GIT_BRANCH. Aborting script"
#  exit 1
#fi

if [ ! -z $PLATFORM_PROVIDED ]; then
  if [[ "$PLATFORMS" != *$PLATFORM_PROVIDED* ]]; then
    printWarn "WARNING: Skipping building of $TAG_SUFFIX images for $PLATFORM_PROVIDED: currently not supported! (supported $PLATFORMS)"
    exit 0
  fi
fi
DATACLAY_VERSION=$(cat $ORCHDIR/VERSION.txt)
export DATACLAY_VERSION="${DATACLAY_VERSION//.dev/}"
export DEFAULT_NORMAL_TAG="$(get_container_version)"
export DEFAULT_TAG="$(get_container_version)${TAG_SUFFIX}"
export BASE_VERSION_TAG="$(get_container_version)${TAG_SUFFIX}"
export CLIENT_TAG="$(get_container_version)${TAG_SUFFIX}"
export DEFAULT_JDK_TAG="$(get_container_version jdk$DEFAULT_JAVA)${TAG_SUFFIX}"
export DEFAULT_PY_TAG="$(get_container_version py$DEFAULT_PYTHON)${TAG_SUFFIX}"
export DEFAULT_JDK_CLIENT_TAG="$(get_container_version jdk$CLIENT_JAVA)${TAG_SUFFIX}"
export DEFAULT_PY_CLIENT_TAG="$(get_container_version py$CLIENT_PYTHON)${TAG_SUFFIX}"
if [ ! -z $EXECUTION_ENVIRONMENT ]; then 
	export EXECUTION_ENVIRONMENT_TAG="$(get_container_version $EXECUTION_ENVIRONMENT)${TAG_SUFFIX}"
fi
CONTAINER=${PWD##*/}

if [[ $EXECUTION_ENVIRONMENT == jdk* ]]; then 
	export JAR_VERSION=$(grep version $DATACLAY_DOCKER_DIR/logicmodule/javaclay/pom.xml | grep -v -e '<?xml|~'| head -n 1 | sed 's/[[:space:]]//g' | sed -E 's/<.{0,1}version>//g' | awk '{print $1}')
	export JAVA_VERSION=${EXECUTION_ENVIRONMENT#"jdk"}
elif [[ $EXECUTION_ENVIRONMENT == py* ]]; then
	export PYTHON_VERSION=${EXECUTION_ENVIRONMENT#"py"}
	# Get python version without subversion to install it in some packages
	export PYTHON_PIP_VERSION=$(echo $PYTHON_VERSION | awk -F '.' '{print $1}')
	setuppy_version=`cat $DATACLAY_DOCKER_DIR/dspython/pyclay/VERSION.txt`
else 
	printWarn "WARNING: Execution environment not specified. Using default ones."
fi
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
#=== FUNCTION ================================================================
# NAME: deploy
# DESCRIPTION: Deploy to DockerHub and retry if connection fails
#=============================================================================
function deploy {
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
  echo "$COMMAND"
  export n=0
  until [ "$n" -ge 5 ] # Retry maximum 5 times
  do
    echo "************* Pushing image $IMAGE (retry $n) *************"
    eval "$COMMAND" && break
    n=$((n+1))
    sleep 15
  done
  if [ "$n" -eq 5 ]; then
    echo "ERROR: $IMAGE could not be pushed"
    return 1
  fi

  echo "************* $IMAGE IMAGE PUSHED! (in $n retries) *************"
  echo "$(($SECONDS / 60)) minutes and $(($SECONDS % 60)) seconds elapsed."
}
#==============================================================================
grn=$'\e[1;32m'; blu=$'\e[1;34m'; red=$'\e[1;91m'; end=$'\e[0m';
function printMsg { echo "${blu}[$(basename $0)] $1 ${end}"; }
function printError { echo "${red}======== $1 ========${end}"; }
################################## OPTIONS ####################################
set -e
CONFIGDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
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
        --do-not-package)
        	export PACKAGE_JAR="false"
        	;;
        --share-builder)
          export SHARE_BUILDER="true"
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
        	exit -1
            ;;
    esac
    shift
done
###############################################################################
source $PLATFORMS_FILE

#GIT_BRANCH=$(git for-each-ref --format='%(objectname) %(refname:short)' refs/heads | awk "/^$(git rev-parse HEAD)/ {print \$2}")
#if [[ "$GIT_BRANCH" != "$BRANCH_TO_CHECK" ]]; then
#  printError "Branch is not $BRANCH_TO_CHECK. Found $GIT_BRANCH. Aborting script"
#  exit 1
#fi

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

echo "DATACLAY_VERSION=$DATACLAY_VERSION"
echo "DEFAULT_TAG=$DEFAULT_TAG"
echo "BASE_VERSION_TAG=$BASE_VERSION_TAG"
echo "CLIENT_TAG=$CLIENT_TAG"
echo "DEFAULT_JDK_TAG=$DEFAULT_JDK_TAG"
echo "DEFAULT_PY_TAG=$DEFAULT_PY_TAG"
echo "DEFAULT_JDK_CLIENT_TAG=$DEFAULT_JDK_CLIENT_TAG"
echo "DEFAULT_PY_CLIENT_TAG=$DEFAULT_PY_CLIENT_TAG"
echo "EXECUTION_ENVIRONMENT_TAG=$EXECUTION_ENVIRONMENT_TAG"

if [[ $EXECUTION_ENVIRONMENT == jdk* ]]; then 
	export JAR_VERSION=$(grep version $DATACLAY_DOCKER_DIR/logicmodule/javaclay/pom.xml | grep -v -e '<?xml|~'| head -n 1 | sed 's/[[:space:]]//g' | sed -E 's/<.{0,1}version>//g' | awk '{print $1}')
	export JAVA_VERSION=${EXECUTION_ENVIRONMENT#"jdk"}
	echo "Build Java version will be:$grn $JAVA_VERSION $end" 
	echo "Default Java version will be:$grn $DEFAULT_JAVA $end" 
	echo "Current defined version in pom.xml:$grn $JAR_VERSION $end"
elif [[ $EXECUTION_ENVIRONMENT == py* ]]; then
	export PYTHON_VERSION=${EXECUTION_ENVIRONMENT#"py"}
	# Get python version without subversion to install it in some packages
	export PYTHON_PIP_VERSION=$(echo $PYTHON_VERSION | awk -F '.' '{print $1}')
	setuppy_version=`cat $DATACLAY_DOCKER_DIR/dspython/pyclay/VERSION.txt`
	echo "Build Python version will be:$grn $PYTHON_VERSION $end" 
	echo "Default Python version will be:$grn $DEFAULT_PYTHON $end" 
	echo "Current defined version in setup.py:$grn $setuppy_version.dev$(date +%Y%m%d) $end" 	
else 
	echo "WARNING: Execution environment not specified. Using default ones."
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
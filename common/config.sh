#!/bin/bash
#===================================================================================
#
# FILE: config.sh
#
# USAGE: stale-config.sh
#
# DESCRIPTION: Check requirements to build/deploy docker and singularity images are
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
# NAME: check_requirements
# DESCRIPTION: Check requirements
# PARAMETER 1: ---
#===============================================================================
function check_requirements { 
	echo "Checking requirements ... "
	source $CONFIGDIR/REQUIREMENTS.txt
	
	# check commands
	for COMMAND in ${INSTALLED_REQUIREMENTS[@]}; do
		printf "Checking if $COMMAND is installed..."
		if ! foobar_loc="$(type -p "$COMMAND")" || [[ -z $foobar_loc ]]; then
			echo "ERROR: please make sure $COMMAND is installed"
		  	exit -1
		fi 
		printf "OK\n"
	done

	printf "Checking if java version >= $REQUIRED_JAVA_VERSION..."
	version=$("java" -version 2>&1 | awk -F '"' '/version/ {print $2}' | awk -F '.' '{print $1}')
	if (("$version" < "$REQUIRED_JAVA_VERSION")); then       
	    echo "ERROR: java version is less than $REQUIRED_JAVA_VERSION"
		exit 1
	fi
	printf "OK\n"
	printf "Checking if javac version >= $REQUIRED_JAVA_VERSION..."	
	version=$("javac" -version 2>&1 | awk '{print $2}' | awk -F '.' '{print $1}')
	if (("$version" < "$REQUIRED_JAVA_VERSION")); then    
	    echo "ERROR: javac version is less than $REQUIRED_JAVA_VERSION"
		exit 1
	fi
	printf "OK\n"
	echo "Requirements accomplished! "
	
}

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

grn=$'\e[1;32m'; blu=$'\e[1;34m'; red=$'\e[1;91m'; end=$'\e[0m';
function printMsg { echo "${blu}[$(basename $0)] $1 ${end}"; }
function printError { echo "${red}======== $1 ========${end}"; }
################################## OPTIONS ####################################
set -e
export DEV=false
export PACKAGE_JAR=true
export SINGULARITY_CHECK=false
DONOTPROMPT=false

DOCKERFILE=""
TAG_SUFFIX=""

while test $# -gt 0
do
    case "$1" in
        --dev) export DEV=true
            ;;
        --ee) 
        	shift 
        	EXECUTION_ENVIRONMENT=$1 
        	;;
        --branch) 
        	# If branch is named develop, --dev option is set
        	shift 
        	BRANCH=$1 
        	if [ $BRANCH == "develop" ]; then 
        		export DEV=true
        	fi
        	;;
        -y) 
        	DONOTPROMPT=true 
        	;;
        --do-not-package) 
        	export PACKAGE_JAR=false 
        	;;
        --slim) 
        	export DOCKERFILE="-f slim.Dockerfile" 
        	export TAG_SUFFIX="-slim"
        	;;
        --alpine) 
        	export DOCKERFILE="-f alpine.Dockerfile" 
        	export TAG_SUFFIX="-alpine"
        	;;
        --singularity) 
        	SINGULARITY_CHECK=true
        	INSTALLED_REQUIREMENTS+=("singularity")
            ;;
        *) echo "Bad option $1"
        	exit -1
            ;;
    esac
    shift
done
###############################################################################
CONFIGDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
ORCHDIR=$CONFIGDIR/../orchestration/
DATACLAY_DOCKER_DIR=$CONFIGDIR/../docker/
source $CONFIGDIR/PLATFORMS.txt

## Checks
check_requirements
if [ "$DEV" = false ] ; then
	GIT_BRANCH=$(git name-rev --name-only HEAD)
	if [[ "$GIT_BRANCH" != "master" ]]; then
	  echo 'Aborting deployment, only master branch can deploy a release. Use --dev instead.';
	  exit 1;
	fi
fi
DATACLAY_VERSION=$(cat $ORCHDIR/VERSION.txt)
export DATACLAY_VERSION="${DATACLAY_VERSION//.dev/}"
export DEFAULT_TAG="$(get_container_version)${TAG_SUFFIX}"
export BASE_VERSION_TAG="$(get_container_version)${TAG_SUFFIX}"
export CLIENT_TAG="$(get_container_version)${TAG_SUFFIX}"
export DEFAULT_JDK_TAG="$(get_container_version jdk$DEFAULT_JAVA)${TAG_SUFFIX}"
export DEFAULT_PY_TAG="$(get_container_version py$DEFAULT_PYTHON)${TAG_SUFFIX}"
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
echo "EXECUTION_ENVIRONMENT_TAG=$EXECUTION_ENVIRONMENT_TAG"

if [[ $EXECUTION_ENVIRONMENT == jdk* ]]; then 
	export JAR_VERSION=$(grep version $DATACLAY_DOCKER_DIR/logicmodule/javaclay/pom.xml | grep -v -e '<?xml|~'| head -n 1 | sed 's/[[:space:]]//g' | sed -E 's/<.{0,1}version>//g' | awk '{print $1}')
	export JAR_NAME=dataclay-${JAR_VERSION}-jar-with-dependencies.jar
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


# No support for alpine jdk 11 and ARM 32 available 
if [[ "$JAVA_VERSION" == "11" ]] && [[ "$TAG_SUFFIX" == "-alpine" ]]; then 
	export PLATFORMS=${PLATFORMS/linux\/arm\/v7,}
	echo "WARNING: No support for ARMv7 in ALPINE with JDK 11. Using platforms: $PLATFORMS"
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
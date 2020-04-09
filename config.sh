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
	echo " Checking requirements ... "
	source $SCRIPTDIR/REQUIREMENTS.txt
	
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

	printf "Checking if docker version >= $REQUIRED_DOCKER_VERSION..."
	version=$(docker version --format '{{.Server.Version}}')
	if [[ "$version" < "$REQUIRED_DOCKER_VERSION" ]]; then       
	    echo "ERROR: Docker version is less than $REQUIRED_DOCKER_VERSION"
		exit 1
	fi
	printf "OK\n"
	echo " Requirements accomplished! "
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

################################## OPTIONS #############################################
SINGULARITY_CHECK=false
while test $# -gt 0
do
    case "$1" in
        --singularity) 
        	SINGULARITY_CHECK=true
        	INSTALLED_REQUIREMENTS+=("singularity")
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

source $SCRIPTDIR/PLATFORMS.txt
check_requirements

DATACLAY_VERSION=$(cat $SCRIPTDIR/VERSION.txt)
DEFAULT_TAG="$(get_container_version)"
DEFAULT_JDK_TAG="$(get_container_version jdk$DEFAULT_JAVA)"
DEFAULT_PY_TAG="$(get_container_version py$DEFAULT_PYTHON)"
BASE_VERSION_TAG="$(get_container_version)"
CLIENT_TAG="$(get_container_version)"
# get version from pom.xml 
JAR_VERSION=$(grep version $SCRIPTDIR/logicmodule/javaclay/pom.xml | grep -v -e '<?xml|~'| head -n 1 | sed 's/[[:space:]]//g' | sed -E 's/<.{0,1}version>//g' | awk '{print $1}')
JAR_NAME=dataclay-${JAR_VERSION}-jar-with-dependencies.jar

declare -A JAVA_CONTAINER_VERSIONS
declare -A PYTHON_CONTAINER_VERSIONS
if [ -z $REPOSITORY ]; then REPOSITORY=bscdataclay; fi 
echo " Going to build/push following images: "
echo "	$REPOSITORY/base:${BASE_VERSION_TAG}"
echo "	$REPOSITORY/logicmodule:${DEFAULT_TAG}"
echo "	$REPOSITORY/dsjava:${DEFAULT_TAG}"
echo " 	$REPOSITORY/dspython:${DEFAULT_TAG}"
echo "	$REPOSITORY/client:${CLIENT_TAG}"
for JAVA_VERSION in ${SUPPORTED_JAVA_VERSIONS[@]}; do
	DATACLAY_DOCKER_TAG="$(get_container_version jdk$JAVA_VERSION)"
	JAVA_CONTAINER_VERSIONS+=([${JAVA_VERSION}]=${DATACLAY_DOCKER_TAG})
	echo "	$REPOSITORY/logicmodule:${DATACLAY_DOCKER_TAG}"
	echo "	$REPOSITORY/dsjava:${DATACLAY_DOCKER_TAG}"
done
for PYTHON_VERSION in ${SUPPORTED_PYTHON_VERSIONS[@]}; do
	DATACLAY_DOCKER_TAG="$(get_container_version py$PYTHON_VERSION)"
	PYTHON_CONTAINER_VERSIONS+=([${PYTHON_VERSION}]=${DATACLAY_DOCKER_TAG})
	echo "	$REPOSITORY/dspython:${DATACLAY_DOCKER_TAG}"
done
version=`grep -m 1 "<version>" $SCRIPTDIR/logicmodule/javaclay/pom.xml`
setuppy_version=`cat $SCRIPTDIR/dspython/pyclay/VERSION.txt`
echo "Default Java version will be:$grn $DEFAULT_JAVA $end" 
echo "Default Python version will be:$grn $DEFAULT_PYTHON $end" 
echo "Current defined version in pom.xml:$grn $version $end" 
echo "Current defined version in setup.py:$grn $setuppy_version.dev$(date +%Y%m%d) $end" 
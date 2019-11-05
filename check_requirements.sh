#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
INSTALLED_REQUIREMENTS=("mvn" "java" "javac" "python" "docker")
REQUIRED_JAVA_VERSION=8
REQUIRED_DOCKER_VERSION=19

function check_java_version { 
	printf "Checking if java version >= $REQUIRED_JAVA_VERSION..."
	version=$("java" -version 2>&1 | awk -F '"' '/version/ {print $2}' | awk -F '.' '{print $1}')
	if (("$version" < "$REQUIRED_JAVA_VERSION")); then       
	    echo "ERROR: java version is less than $REQUIRED_JAVA_VERSION"
		return -1
	fi
	printf "OK\n"
	printf "Checking if javac version >= $REQUIRED_JAVA_VERSION..."	
	version=$("javac" -version 2>&1 | awk '{print $2}' | awk -F '.' '{print $1}')
	if (("$version" < "$REQUIRED_JAVA_VERSION")); then    
	    echo "ERROR: javac version is less than $REQUIRED_JAVA_VERSION"
		return -1
	fi
	printf "OK\n"
}

function check_docker_version { 
	printf "Checking if docker version >= $REQUIRED_DOCKER_VERSION..."
	version=$(docker version --format '{{.Server.Version}}')
	if [[ "$version" < "$REQUIRED_DOCKER_VERSION" ]]; then       
	    echo "ERROR: Docker version is less than $REQUIRED_DOCKER_VERSION"
		return -1
	fi
	printf "OK\n"
}

################################## MAIN #############################################

# check java
check_java_version java 
if [ $? -ne 0 ]; then exit $?; fi

# check commands
for COMMAND in ${INSTALLED_REQUIREMENTS[@]}; do
	printf "Checking if $COMMAND is installed..."
	if ! foobar_loc="$(type -p "$COMMAND")" || [[ -z $foobar_loc ]]; then
		echo "ERROR: please make sure $COMMAND is installed"
	  	exit -1
	fi 
	printf "OK\n"
done
check_docker_version
if [ $? -ne 0 ]; then exit $?; fi

if [ "$PUSH_DOCKERS" = true ] ; then
	prepare_docker_builder
	if [ $? -ne 0 ]; then exit $?; fi
fi


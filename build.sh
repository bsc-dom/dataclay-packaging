#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
grn=$'\e[1;32m'
blu=$'\e[1;34m'
red=$'\e[1;91m'
end=$'\e[0m'
function printMsg { 
  echo "${blu}[dataClay build] $1 ${end}"
}
function printError { 
  echo "${red}======== $1 ========${end}"
}

SUPPORTED_JAVA_VERSIONS=(8 11)
SUPPORTED_PYTHON_VERSIONS=(3.6)
INSTALLED_REQUIREMENTS=("mvn" "java" "javac" "python" "docker")
DEFAULT_JAVA=11
DEFAULT_PYTHON=3.6

# Update versions here
DATACLAY_RELEASE_VERSION=2.0
DATACLAY_DEVELOPMENT_VERSION=-1

################################## VERSIONS #############################################

function get_container_version { 
	if [ $# -gt 0 ]; then 
		EE_VERSION=$1 # i.e. can be python py3.6 or jdk8
		DATACLAY_EE_VERSION="${EE_VERSION//./}"
		if [ "$DATACLAY_DEVELOPMENT_VERSION" != "-1" ] ; then
			DATACLAY_CONTAINER_VERSION="${DATACLAY_RELEASE_VERSION}.${DATACLAY_EE_VERSION}.dev${DATACLAY_DEVELOPMENT_VERSION}"
		else 
			DATACLAY_CONTAINER_VERSION="$DATACLAY_RELEASE_VERSION.${DATACLAY_EE_VERSION}"
		fi 
	else 
		if [ "$DATACLAY_DEVELOPMENT_VERSION" != "-1" ] ; then
			DATACLAY_CONTAINER_VERSION="${DATACLAY_RELEASE_VERSION}.dev${DATACLAY_DEVELOPMENT_VERSION}"
		else 
			DATACLAY_CONTAINER_VERSION="$DATACLAY_RELEASE_VERSION"
	fi 
	fi
	echo ${DATACLAY_CONTAINER_VERSION}
}

################################## MAIN #############################################
printMsg "'"'
      _       _         _____ _             
     | |     | |       / ____| |            
   __| | __ _| |_ __ _| |    | | __ _ _   _ 
  / _` |/ _` | __/ _` | |    | |/ _` | | | |
 | (_| | (_| | || (_| | |____| | (_| | |_| |  build script
  \__,_|\__,_|\__\__,_|\_____|_|\__,_|\__, |
                                       __/ |
                                      |___/ 
'"'"
printMsg " Welcome to dataClay build script!"

# Check requirements
printMsg " Checking requirements ... "
./check_requirements.sh
printMsg " Requirements accomplished! "
################################## BUILD #############################################

DEFAULT_TAG="$(get_container_version)"
DEFAULT_JDK_TAG="$(get_container_version jdk$DEFAULT_JAVA)"
DEFAULT_PY_TAG="$(get_container_version py$DEFAULT_PYTHON)"

# BASE IMAGES 
pushd $SCRIPTDIR/base
BASE_VERSION_TAG="$(get_container_version)"
printMsg "Building image named bscdataclay/base:$BASE_VERSION_TAG"
docker build -t bscdataclay/base:$BASE_VERSION_TAG .
printMsg "bscdataclay/base:$BASE_VERSION_TAG IMAGE DONE!" 
popd

# LOGICMODULE
pushd $SCRIPTDIR/logicmodule
for JAVA_VERSION in ${SUPPORTED_JAVA_VERSIONS[@]}; do
	VERSION="$(get_container_version jdk$JAVA_VERSION)"
	printMsg "Building image named bscdataclay/logicmodule:$VERSION"
	docker build --build-arg BASE_VERSION=$BASE_VERSION_TAG --build-arg JDK=$JAVA_VERSION -t bscdataclay/logicmodule:$VERSION .
	printMsg "bscdataclay/logicmodule:$VERSION IMAGE DONE!"
done
popd 

# DSJAVA
pushd $SCRIPTDIR/dsjava
for JAVA_VERSION in ${SUPPORTED_JAVA_VERSIONS[@]}; do
	VERSION="$(get_container_version jdk$JAVA_VERSION)"
	printMsg "Building image named bscdataclay/dsjava:$VERSION"
	docker build --build-arg LOGICMODULE_VERSION=$VERSION -t bscdataclay/dsjava:$VERSION .
	printMsg " bscdataclay/dsjava:$VERSION DONE!"
done
popd 

# DSPYTHON
pushd $SCRIPTDIR/dspython
for PYTHON_VERSION in ${SUPPORTED_PYTHON_VERSIONS[@]}; do
	VERSION="$(get_container_version py$PYTHON_VERSION)"
	# Get python version without subversion to install it in some packages
	PYTHON_PIP_VERSION=$PYTHON_VERSION
	PYTHON_PIP_VERSION=$(echo $PYTHON_VERSION | awk -F '.' '{print $1}')
	if [ $PYTHON_PIP_VERSION -eq "2" ]; then 
		PYTHON_PIP_VERSION=""
	fi 
	printMsg "Building image named bscdataclay/dspython:$VERSION python version $DEFAULT_PYTHON and pip version $PYTHON_PIP_VERSION"
	docker build --build-arg BASE_VERSION=$BASE_VERSION_TAG \
				 --build-arg DATACLAY_PYVER=$PYTHON_VERSION \
				 --build-arg PYTHON_PIP_VERSION=$PYTHON_PIP_VERSION -t bscdataclay/dspython:$VERSION .
	printMsg "bscdataclay/dspython:$VERSION DONE!"
done
popd 

# CLIENT 
pushd $SCRIPTDIR/client
# client will not have execution environemnt in version, like pypi
JAVACLAY_TAG="$(get_container_version jdk$DEFAULT_JAVA)"
PYCLAY_TAG="$(get_container_version py$DEFAULT_PYTHON)"
CLIENT_TAG="$(get_container_version)"
printMsg "Building image named bscdataclay/client:$CLIENT_TAG"
docker build --build-arg DATACLAY_DSPYTHON_DOCKER_TAG=$PYCLAY_TAG \
			 --build-arg DATACLAY_LOGICMODULE_DOCKER_TAG=$JAVACLAY_TAG \
			 -t bscdataclay/client:$CLIENT_TAG .
printMsg "bscdataclay/client:$CLIENT_TAG DONE!"
popd 


## Tag default versions 
docker tag bscdataclay/logicmodule:$DEFAULT_JDK_TAG bscdataclay/logicmodule:$DEFAULT_TAG
docker tag bscdataclay/dsjava:$DEFAULT_JDK_TAG bscdataclay/dsjava:$DEFAULT_TAG
docker tag bscdataclay/dspython:$DEFAULT_PY_TAG bscdataclay/dspython:$DEFAULT_TAG
docker tag bscdataclay/client:$CLIENT_TAG bscdataclay/cmd:$CLIENT_TAG

# Tag latest
docker tag bscdataclay/base:$DEFAULT_TAG bscdataclay/base
docker tag bscdataclay/logicmodule:$DEFAULT_TAG bscdataclay/logicmodule
docker tag bscdataclay/dsjava:$DEFAULT_TAG bscdataclay/dsjava
docker tag bscdataclay/dspython:$DEFAULT_TAG bscdataclay/dspython
docker tag bscdataclay/client:$DEFAULT_TAG bscdataclay/client
docker tag bscdataclay/cmd:$DEFAULT_TAG bscdataclay/cmd

# Check docker images 
printMsg "Generated images:"
docker images | grep "bscdataclay/base"
docker images | grep "bscdataclay/logicmodule"
docker images | grep "bscdataclay/dsjava"
docker images | grep "bscdataclay/dspython"
docker images | grep "bscdataclay/client"
docker images | grep "bscdataclay/cmd"

echo "${grn}[dataClay build] Done! "
echo ""

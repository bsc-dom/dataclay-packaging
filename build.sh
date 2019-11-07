#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
SUPPORTED_JAVA_VERSIONS=(8 11)
SUPPORTED_PYTHON_VERSIONS=(3.6)
INSTALLED_REQUIREMENTS=("mvn" "java" "javac" "python" "docker")
DEFAULT_JAVA=8
DEFAULT_PYTHON=3.6

# Update versions here
DATACLAY_RELEASE_VERSION=2.0
DATACLAY_DEVELOPMENT_VERSION=22

################################## VERSIONS #############################################

function get_client_container_version { 
	if [ "$DATACLAY_DEVELOPMENT_VERSION" != "-1" ] ; then
		DATACLAY_CONTAINER_VERSION="${DATACLAY_RELEASE_VERSION}.dev${DATACLAY_DEVELOPMENT_VERSION}"
	else 
		DATACLAY_CONTAINER_VERSION="$DATACLAY_RELEASE_VERSION"
	fi 
	echo ${DATACLAY_CONTAINER_VERSION}
}

function get_java_container_version {
    JAVA_VERSION=$1 
	echo $(get_container_version jdk $JAVA_VERSION) 
}

function get_python_container_version {
	PYTHON_VERSION=$1 
	echo $(get_container_version py $PYTHON_VERSION) 
}

function get_container_version { 
	PREFIX=$1
	EE_VERSION=$2 # i.e. can be python 3.6 or java 8
	DATACLAY_EE_VERSION="${PREFIX}${EE_VERSION//./}"
	if [ "$DATACLAY_DEVELOPMENT_VERSION" != "-1" ] ; then
		DATACLAY_CONTAINER_VERSION="${DATACLAY_RELEASE_VERSION}.${DATACLAY_EE_VERSION}.dev${DATACLAY_DEVELOPMENT_VERSION}"
	else 
		DATACLAY_CONTAINER_VERSION="$DATACLAY_RELEASE_VERSION.${DATACLAY_EE_VERSION}"
	fi 
	echo ${DATACLAY_CONTAINER_VERSION}
}

pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}


################################## MAIN #############################################


echo "'"'
      _       _         _____ _             
     | |     | |       / ____| |            
   __| | __ _| |_ __ _| |    | | __ _ _   _ 
  / _` |/ _` | __/ _` | |    | |/ _` | | | |
 | (_| | (_| | || (_| | |____| | (_| | |_| |  build script
  \__,_|\__,_|\__\__,_|\_____|_|\__,_|\__, |
                                       __/ |
                                      |___/ 
'"'"
echo " Welcome to dataClay build script!"

# Check requirements
echo " *** Checking requirements ... *** "
./check_requirements.sh
echo " *** Requirements accomplished :) *** "

################################## BUILD #############################################

# BASE IMAGES 
for JAVA_VERSION in ${SUPPORTED_JAVA_VERSIONS[@]}; do
	pushd $SCRIPTDIR/base/jdk$JAVA_VERSION
	BASE_VERSION_TAG="$(get_java_container_version $JAVA_VERSION)"
	echo "************* Building image named bscdataclay/base:$BASE_VERSION_TAG *************"
	docker build --build-arg BASE_JAVA_VERSION=$JAVA_VERSION -t bscdataclay/base:$BASE_VERSION_TAG .
	echo "************* bscdataclay/base:$BASE_VERSION_TAG IMAGE DONE! *************"
	popd 
done

# LOGICMODULE
pushd $SCRIPTDIR/logicmodule
BASE_VERSION="$(get_java_container_version $DEFAULT_JAVA)"
JAVACLAY_TAG=$BASE_VERSION
echo "************* Building image named bscdataclay/logicmodule:$JAVACLAY_TAG *************"
docker build --build-arg BASE_VERSION=$BASE_VERSION -t bscdataclay/logicmodule:$JAVACLAY_TAG .
echo "************* bscdataclay/logicmodule:$JAVACLAY_TAG IMAGE DONE! *************"
popd 

# DSJAVA
pushd $SCRIPTDIR/dsjava
echo "************* Building image named bscdataclay/dsjava:$JAVACLAY_TAG *************"
docker build --build-arg LOGICMODULE_VERSION=$JAVACLAY_TAG -t bscdataclay/dsjava:$JAVACLAY_TAG .
echo "************* bscdataclay/dsjava:$JAVACLAY_TAG DONE! *************"
popd 

# DSPYTHON
pushd $SCRIPTDIR/dspython
PYCLAY_TAG="$(get_python_container_version $DEFAULT_PYTHON)"
# Get python version without subversion to install it in some packages
PYTHON_PIP_VERSION=$DEFAULT_PYTHON
PYTHON_PIP_VERSION=$(echo $DEFAULT_PYTHON | awk -F '.' '{print $1}')
if [ $PYTHON_PIP_VERSION -eq "2" ]; then 
	PYTHON_PIP_VERSION=""
fi 
echo "************* Building image named bscdataclay/dspython:$PYCLAY_TAG python version $DEFAULT_PYTHON and pip version $PYTHON_PIP_VERSION *************"
docker build --build-arg BASE_VERSION=$BASE_VERSION \
			 --build-arg DATACLAY_PYVER=$DEFAULT_PYTHON \
			 --build-arg PYTHON_PIP_VERSION=$PYTHON_PIP_VERSION -t bscdataclay/dspython:$PYCLAY_TAG .
echo "************* bscdataclay/dsjava:$PYCLAY_TAG DONE! *************"
popd 

# CLIENT 
pushd $SCRIPTDIR/client
# client will not have execution environemnt in version, like pypi
CLIENT_TAG="$(get_client_container_version $DEFAULT_PYTHON)"
echo "************* Building image named bscdataclay/client:$CLIENT_TAG *************"
docker build --build-arg DATACLAY_DSPYTHON_DOCKER_TAG=$PYCLAY_TAG \
			 --build-arg DATACLAY_LOGICMODULE_DOCKER_TAG=$JAVACLAY_TAG \
			 -t bscdataclay/client:$CLIENT_TAG .
echo "************* bscdataclay/client:$CLIENT_TAG DONE! *************"
popd 

echo " ===== Done! ====="

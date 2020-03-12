#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
grn=$'\e[1;32m'
blu=$'\e[1;34m'
red=$'\e[1;91m'
end=$'\e[0m'
set -e

################################## FUNCTIONS #############################################

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

function printMsg { 
  echo "${blu}[dataClay build] $1 ${end}"
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

################################## SUPPORTED PLATFORMS #############################################
SUPPORTED_JAVA_VERSIONS=(8 11)
SUPPORTED_PYTHON_VERSIONS=(3.6 3.7)
DEFAULT_JAVA=11
DEFAULT_PYTHON=3.7
################################## VERSIONING #############################################
DATACLAY_RELEASE_VERSION=$(cat VERSION.txt)
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
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

echo " -- I'm going to build docker images: "
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

################################## BUILD #############################################

# CREATE DATACLAY JAR
pushd $SCRIPTDIR/logicmodule/javaclay
mvn package -DskipTests=true
popd

# BASE IMAGES 
pushd $SCRIPTDIR/base
printMsg "Building image named bscdataclay/base:$BASE_VERSION_TAG"
docker build -t bscdataclay/base:$BASE_VERSION_TAG .
printMsg "bscdataclay/base:$BASE_VERSION_TAG IMAGE DONE!" 
popd

# LOGICMODULE
pushd $SCRIPTDIR/logicmodule
for JAVA_VERSION in ${SUPPORTED_JAVA_VERSIONS[@]}; do
	VERSION="$(get_container_version jdk$JAVA_VERSION)"
	printMsg "Building image named bscdataclay/logicmodule:$VERSION"
	docker build --build-arg BASE_VERSION=$BASE_VERSION_TAG --build-arg JDK=$JAVA_VERSION --build-arg LOCAL_JAR=$JAR_NAME -t bscdataclay/logicmodule:$VERSION .
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
	printMsg "Building image named bscdataclay/dspython:$VERSION python version $PYTHON_VERSION and pip version $PYTHON_PIP_VERSION"
	docker build --build-arg BASE_VERSION=$BASE_VERSION_TAG \
				 --build-arg DATACLAY_PYVER=$PYTHON_VERSION \
				 --build-arg PYTHON_PIP_VERSION=$PYTHON_PIP_VERSION -t bscdataclay/dspython:$VERSION .
	printMsg "bscdataclay/dspython:$VERSION DONE!"
done
popd 

# CLIENT 
pushd $SCRIPTDIR/client
# client will not have execution environemnt in version, like pypi
printMsg "Building image named bscdataclay/client:$CLIENT_TAG"
docker build --build-arg DATACLAY_DSPYTHON_DOCKER_TAG=$DEFAULT_PY_TAG \
			 --build-arg DATACLAY_LOGICMODULE_DOCKER_TAG=$DEFAULT_JDK_TAG \
			 --build-arg DATACLAY_PYVER=$DEFAULT_PYTHON \
			 -t bscdataclay/client:$CLIENT_TAG .
printMsg "bscdataclay/client:$CLIENT_TAG DONE!"
popd 


## Tag default versions 
docker tag bscdataclay/logicmodule:$DEFAULT_JDK_TAG bscdataclay/logicmodule:$DEFAULT_TAG
docker tag bscdataclay/dsjava:$DEFAULT_JDK_TAG bscdataclay/dsjava:$DEFAULT_TAG
docker tag bscdataclay/dspython:$DEFAULT_PY_TAG bscdataclay/dspython:$DEFAULT_TAG

# Tag latest
if [ "$DEV" = false ] ; then
	docker tag bscdataclay/base:$DEFAULT_TAG bscdataclay/base
	docker tag bscdataclay/logicmodule:$DEFAULT_TAG bscdataclay/logicmodule
	docker tag bscdataclay/dsjava:$DEFAULT_TAG bscdataclay/dsjava
	docker tag bscdataclay/dspython:$DEFAULT_TAG bscdataclay/dspython
	docker tag bscdataclay/client:$DEFAULT_TAG bscdataclay/client
fi 

# Check docker images 
printMsg "Generated images:"
docker images | grep "bscdataclay/base"
docker images | grep "bscdataclay/logicmodule"
docker images | grep "bscdataclay/dsjava"
docker images | grep "bscdataclay/dspython"
docker images | grep "bscdataclay/client"

echo "${grn}[dataClay build] Done! "
echo ""

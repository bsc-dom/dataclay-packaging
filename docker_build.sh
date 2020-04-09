#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
grn=$'\e[1;32m'; blu=$'\e[1;34m'; red=$'\e[1;91m'; end=$'\e[0m';
function printMsg { echo "${blu}[$(basename $0)] $1 ${end}"; }
function printError { echo "${red}======== $1 ========${end}"; }
set -e
################################## OPTIONS #############################################
export DEV=false
# idiomatic parameter and option handling in sh
while test $# -gt 0
do
    case "$1" in
        --dev) export DEV=true
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
REPOSITORY="bscdataclay"
source $SCRIPTDIR/config.sh

################################## BUILD #############################################

# CREATE DATACLAY JAR
pushd $SCRIPTDIR/logicmodule/javaclay
mvn package -DskipTests=true
popd

# BASE IMAGES 
pushd $SCRIPTDIR/base
printMsg "Building image named $REPOSITORY/base:$BASE_VERSION_TAG"
docker build -t $REPOSITORY/base:$BASE_VERSION_TAG .
printMsg "$REPOSITORY/base:$BASE_VERSION_TAG IMAGE DONE!" 
popd

# LOGICMODULE
pushd $SCRIPTDIR/logicmodule
for JAVA_VERSION in ${!JAVA_CONTAINER_VERSIONS[@]}; do
	VERSION="${JAVA_CONTAINER_VERSIONS[$JAVA_VERSION]}"
	printMsg "Building image named $REPOSITORY/logicmodule:$VERSION"
	docker build --build-arg BASE_VERSION=$BASE_VERSION_TAG --build-arg JDK=$JAVA_VERSION --build-arg LOCAL_JAR=$JAR_NAME -t $REPOSITORY/logicmodule:$VERSION .
	printMsg "$REPOSITORY/logicmodule:$VERSION IMAGE DONE!"
done
popd 

# DSJAVA
pushd $SCRIPTDIR/dsjava
for JAVA_VERSION in ${!JAVA_CONTAINER_VERSIONS[@]}; do
	VERSION="${JAVA_CONTAINER_VERSIONS[$JAVA_VERSION]}"
	printMsg "Building image named $REPOSITORY/dsjava:$VERSION"
	docker build --build-arg LOGICMODULE_VERSION=$VERSION -t $REPOSITORY/dsjava:$VERSION .
	printMsg " $REPOSITORY/dsjava:$VERSION DONE!"
done
popd 

# DSPYTHON
pushd $SCRIPTDIR/dspython
for PYTHON_VERSION in ${!PYTHON_CONTAINER_VERSIONS[@]}; do
	VERSION="${PYTHON_CONTAINER_VERSIONS[$PYTHON_VERSION]}"
	# Get python version without subversion to install it in some packages
	PYTHON_PIP_VERSION=$PYTHON_VERSION
	PYTHON_PIP_VERSION=$(echo $PYTHON_VERSION | awk -F '.' '{print $1}')
	printMsg "Building image named $REPOSITORY/dspython:$VERSION python version $PYTHON_VERSION and pip version $PYTHON_PIP_VERSION"
	docker build --build-arg BASE_VERSION=$BASE_VERSION_TAG \
				 --build-arg DATACLAY_PYVER=$PYTHON_VERSION \
				 --build-arg PYTHON_PIP_VERSION=$PYTHON_PIP_VERSION -t $REPOSITORY/dspython:$VERSION .
	printMsg "$REPOSITORY/dspython:$VERSION DONE!"
done
popd 

# CLIENT 
pushd $SCRIPTDIR/client
# client will not have execution environemnt in version, like pypi
printMsg "Building image named $REPOSITORY/client:$CLIENT_TAG"
docker build --build-arg DATACLAY_DSPYTHON_DOCKER_TAG=$DEFAULT_PY_TAG \
			 --build-arg DATACLAY_LOGICMODULE_DOCKER_TAG=$DEFAULT_JDK_TAG \
			 --build-arg DATACLAY_PYVER=$DEFAULT_PYTHON \
			 -t $REPOSITORY/client:$CLIENT_TAG .
printMsg "$REPOSITORY/client:$CLIENT_TAG DONE!"
popd 


## Tag default versions 
docker tag $REPOSITORY/logicmodule:$DEFAULT_JDK_TAG $REPOSITORY/logicmodule:$DEFAULT_TAG
docker tag $REPOSITORY/dsjava:$DEFAULT_JDK_TAG $REPOSITORY/dsjava:$DEFAULT_TAG
docker tag $REPOSITORY/dspython:$DEFAULT_PY_TAG $REPOSITORY/dspython:$DEFAULT_TAG

# Tag latest
if [ "$DEV" = false ] ; then
	docker tag $REPOSITORY/base:$DEFAULT_TAG $REPOSITORY/base
	docker tag $REPOSITORY/logicmodule:$DEFAULT_TAG $REPOSITORY/logicmodule
	docker tag $REPOSITORY/dsjava:$DEFAULT_TAG $REPOSITORY/dsjava
	docker tag $REPOSITORY/dspython:$DEFAULT_TAG $REPOSITORY/dspython
	docker tag $REPOSITORY/client:$DEFAULT_TAG $REPOSITORY/client
fi 

# Check docker images 
printMsg "Generated images:"
docker images | grep "$REPOSITORY/base"
docker images | grep "$REPOSITORY/logicmodule"
docker images | grep "$REPOSITORY/dsjava"
docker images | grep "$REPOSITORY/dspython"
docker images | grep "$REPOSITORY/client"

echo "${grn}[dataClay build] Done! "
echo ""

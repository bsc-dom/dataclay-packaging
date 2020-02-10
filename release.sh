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

DATACLAY_RELEASE_VERSION=2.1
DATACLAY_DEVELOPMENT_VERSION="-1"
DATACLAY_SNAPSHOT_VERSION="-1"

SUPPORTED_JAVA_VERSIONS=(8 11)
SUPPORTED_PYTHON_VERSIONS=(3.6 3.7)
PLATFORMS=linux/amd64,linux/arm/v7

DEFAULT_JAVA=11
DEFAULT_PYTHON=3.7

#URL_DATACLAY_MAVEN_REPO="https://github.com/bsc-ssrg/dataclay-maven.git"

################################## FUNCTIONS #############################################
function check_docker_buildx_version { 
	printf "Checking if docker buildx is available..."
	docker buildx version 2>&1 > /dev/null
	if [ $? -ne 0 ]; then return $?; fi
	printf "OK\n"
}

function prepare_docker_builder { 
	printf "Checking buildx dataclaybuilder exists..."
	docker buildx use dataclaybuilder
	if [ $? -ne 0 ]; then
		printf "ERROR\n" 
		echo "Please, create a new builder named dataclaybuilder i.e. docker buildx create --name dataclaybuilder"
		return -1
	fi 
	printf "OK\n"
	echo "Checking buildx dataclaybuilder with available platforms to simulate..."
	
	BUILDER_PLATFORMS=$(docker buildx inspect --bootstrap | grep Platforms | awk -F":" '{print $2}')
	IFS=',' read -ra BUILDER_PLATFORMS_ARRAY <<< "$BUILDER_PLATFORMS"
	IFS=',' read -ra SUPPORTED_PLATFORMS_ARRAY <<< "$PLATFORMS"
	echo "Dataclaybuilder created with platforms: ${BUILDER_PLATFORMS_ARRAY[@]}"	
	
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

function get_maven_version { 
	if [ "$DATACLAY_DEVELOPMENT_VERSION" != "-1" ] ; then
		DATACLAY_MAVEN_VERSION="${DATACLAY_RELEASE_VERSION}-beta-${DATACLAY_DEVELOPMENT_VERSION}"
	else 
		DATACLAY_MAVEN_VERSION="$DATACLAY_RELEASE_VERSION"
	fi 
	echo $DATACLAY_MAVEN_VERSION
}

function get_pypi_version { 
	if [ "$DATACLAY_DEVELOPMENT_VERSION" != "-1" ] ; then
		DATACLAY_CONTAINER_VERSION="${DATACLAY_RELEASE_VERSION}.dev${DATACLAY_DEVELOPMENT_VERSION}"
	else 
		DATACLAY_CONTAINER_VERSION="$DATACLAY_RELEASE_VERSION"
	fi 
	echo ${DATACLAY_CONTAINER_VERSION}
}

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

pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}


################################## MAIN #############################################


printMsg "'"'
      _       _         _____ _             
     | |     | |       / ____| |            
   __| | __ _| |_ __ _| |    | | __ _ _   _ 
  / _` |/ _` | __/ _` | |    | |/ _` | | | |
 | (_| | (_| | || (_| | |____| | (_| | |_| |  release script
  \__,_|\__,_|\__\__,_|\_____|_|\__,_|\__, |
                                       __/ |
                                      |___/ 
'"'"
printMsg " Welcome to dataClay release script!"

printMsg " Checking requirements ... "
$SCRIPTDIR/check_requirements.sh
prepare_docker_builder
printMsg " Requirements accomplished :) "

################################## VERSIONS #############################################

read -p "Enter dataClay version [$DATACLAY_RELEASE_VERSION]: " dataclay_version
DATACLAY_RELEASE_VERSION=${dataclay_version:-$DATACLAY_RELEASE_VERSION}

read -p "Enter dataClay DEVELOPMENT version or -1 if it's a release [$DATACLAY_DEVELOPMENT_VERSION]: " dataclay_version
DATACLAY_DEVELOPMENT_VERSION=${dataclay_version:-$DATACLAY_DEVELOPMENT_VERSION}

while true; do
	version=`grep -m 1 "<version>" $SCRIPTDIR/logicmodule/javaclay/pom.xml`
	echo "Current defined version in pom.xml: $grn $version $end" 
	read -p "Are you sure pom.xml version is correct (yes/no)? " yn
	case $yn in
		[Yy]* ) break;;
		[Nn]* ) echo "Modify it and try again."; exit;;
		* ) echo "$red Please answer yes or no. $end";;
	esac
done 


while true; do
	version=`grep -m 1 "version" $SCRIPTDIR/dspython/pyclay/setup.py`
	echo "Current defined version in setup.py: $grn $version $end" 
	read -p "Are you sure setup.py version is correct (yes/no)? " yn
	case $yn in
		[Yy]* ) break;;
		[Nn]* ) echo "Modify it and try again."; exit;;
		* ) echo "$red Please answer yes or no. $end";;
	esac
done


#
#echo "In a continuous integration environment, version plays a vital role in keeping the integration build 
#up-to-date while minimizing the amount of rebuilding that is required for each integration step. 
#
#In maven this means that we will push dataclay version $(get_maven_version)-SNAPSHOT
#In pypi this means that we will push dataclay library into testPypi repository with version: $(get_pypi_version)
#In dockers this means that we will push dataclay versions like $(get_container_version jdk$JAVA_VERSION)-SNAPSHOT
# 
#"
#read -p "Do you wish to use it as a ?" yn
#case $yn in
#	[Yy]* ) make install; break;;
#	[Nn]* ) exit;;
#	* ) echo "Please answer yes or no.";;
#esac
#

declare -a MAVEN_LIBS_PUSHED
declare -a PYPI_LIBS_PUSHED
declare -a DOCKER_IMAGES_PUSHED
   
################################## PREPARE #############################################


echo " -- I'm going to push following jar into maven using repository $MAVEN_REPOSITORY: dataclay-$(get_maven_version).jar "
echo " -- I'm going to push python libraries into pypi: dataclay==$(get_pypi_version) "
echo " -- I'm going to push into DockerHub docker images: "
echo "                bscdataclay/base:${DATACLAY_RELEASE_VERSION}"
echo "                bscdataclay/logicmodule:${DATACLAY_RELEASE_VERSION}"
echo "                bscdataclay/dsjava:${DATACLAY_RELEASE_VERSION}"
echo "                bscdataclay/dspython:${DATACLAY_RELEASE_VERSION}"
echo "                bscdataclay/client:${DATACLAY_RELEASE_VERSION}"
for JAVA_VERSION in ${SUPPORTED_JAVA_VERSIONS[@]}; do
	DATACLAY_DOCKER_TAG="$(get_container_version jdk$JAVA_VERSION)"
	echo "                bscdataclay/logicmodule:${DATACLAY_DOCKER_TAG}"
	echo "                bscdataclay/dsjava:${DATACLAY_DOCKER_TAG}"
done
for PYTHON_VERSION in ${SUPPORTED_PYTHON_VERSIONS[@]}; do
	DATACLAY_DOCKER_TAG="$(get_container_version py$PYTHON_VERSION)"
	echo "                bscdataclay/dspython:${DATACLAY_DOCKER_TAG}"
done

################################## PUSH #############################################

DEFAULT_TAG="$(get_container_version)"
DEFAULT_JDK_TAG="$(get_container_version jdk$DEFAULT_JAVA)"
DEFAULT_PY_TAG="$(get_container_version py$DEFAULT_PYTHON)"

# CREATE DATACLAY JAR : IF IT EXISTS WHAT TO DO?
pushd $SCRIPTDIR/logicmodule/javaclay
mvn package -DskipTests=true
mv $SCRIPTDIR/logicmodule/javaclay/target/dataclay-${DATACLAY_RELEASE_VERSION}-jar-with-dependencies.jar $SCRIPTDIR/logicmodule/dataclay.jar
popd

# BASE IMAGES 
pushd $SCRIPTDIR/base
BASE_VERSION_TAG="$(get_container_version)"
echo "************* Pushing image named bscdataclay/base:$BASE_VERSION_TAG *************"
docker buildx build -t bscdataclay/base:$BASE_VERSION_TAG --platform $PLATFORMS --push .
if [ $? -ne 0 ]; then printError "Push failed"; exit 1; fi
DOCKER_IMAGES_PUSHED+=(bscdataclay/base:$BASE_VERSION_TAG)
echo "************* bscdataclay/base:$BASE_VERSION_TAG IMAGE PUSHED! *************" 
popd

# LOGICMODULE
pushd $SCRIPTDIR/logicmodule
for JAVA_VERSION in ${SUPPORTED_JAVA_VERSIONS[@]}; do
	VERSION="$(get_container_version jdk$JAVA_VERSION)"
	echo "************* Pushing image named bscdataclay/logicmodule:$VERSION *************"
	docker buildx build --build-arg JDK=$JAVA_VERSION --build-arg BASE_VERSION=$BASE_VERSION_TAG -t bscdataclay/logicmodule:$VERSION --platform $PLATFORMS --push .
	if [ $? -ne 0 ]; then printError "Push failed"; exit 1; fi
	DOCKER_IMAGES_PUSHED+=(bscdataclay/logicmodule:$VERSION)
	echo "************* bscdataclay/logicmodule:$VERSION IMAGE PUSHED! *************"
done
popd 

# DSJAVA
pushd $SCRIPTDIR/dsjava
for JAVA_VERSION in ${SUPPORTED_JAVA_VERSIONS[@]}; do
	VERSION="$(get_container_version jdk$JAVA_VERSION)"
	echo "************* Building image named bscdataclay/dsjava:$VERSION *************"
	docker buildx build --build-arg LOGICMODULE_VERSION=$VERSION -t bscdataclay/dsjava:$VERSION --platform $PLATFORMS --push .
	if [ $? -ne 0 ]; then printError "Push failed"; exit 1; fi
	DOCKER_IMAGES_PUSHED+=(bscdataclay/dsjava:$VERSION)
	echo "************* bscdataclay/dsjava:$VERSION DONE! *************"
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
	echo "************* Building image named bscdataclay/dspython:$VERSION python version $PYTHON_VERSION and pip version $PYTHON_PIP_VERSION *************"
	docker buildx build --build-arg BASE_VERSION=$BASE_VERSION_TAG \
				 --build-arg DATACLAY_PYVER=$PYTHON_VERSION \
				 --build-arg PYTHON_PIP_VERSION=$PYTHON_PIP_VERSION -t bscdataclay/dspython:$VERSION --platform $PLATFORMS --push .
	if [ $? -ne 0 ]; then printError "Push failed"; exit 1; fi
	DOCKER_IMAGES_PUSHED+=(bscdataclay/dspython:$VERSION)
	echo "************* bscdataclay/dspython:$VERSION DONE! *************"
done
popd 

# CLIENT 
pushd $SCRIPTDIR/client
# client will not have execution environemnt in version, like pypi
JAVACLAY_TAG="$(get_container_version jdk$DEFAULT_JAVA)"
PYCLAY_TAG="$(get_container_version py$DEFAULT_PYTHON)"
CLIENT_TAG="$(get_container_version)"
echo "************* Building image named bscdataclay/client:$CLIENT_TAG *************"
docker buildx build --build-arg DATACLAY_DSPYTHON_DOCKER_TAG=$PYCLAY_TAG \
			 --build-arg DATACLAY_LOGICMODULE_DOCKER_TAG=$JAVACLAY_TAG \
			 --build-arg DATACLAY_PYVER=$DEFAULT_PYTHON \
			 -t bscdataclay/client:$CLIENT_TAG --platform $PLATFORMS --push .
if [ $? -ne 0 ]; then printError "Push failed"; exit 1; fi
DOCKER_IMAGES_PUSHED+=(bscdataclay/client:$CLIENT_TAG) 
echo "************* bscdataclay/client:$CLIENT_TAG DONE! *************"
popd 


## Tag default versions 

docker buildx imagetools create --tag bscdataclay/logicmodule:$DEFAULT_TAG bscdataclay/logicmodule:$DEFAULT_JDK_TAG
if [ $? -ne 0 ]; then printError "bscdataclay/logicmodule:$DEFAULT_TAG push failed"; exit 1; fi
DOCKER_IMAGES_PUSHED+=(bscdataclay/logicmodule:$DEFAULT_TAG) 

docker buildx imagetools create --tag bscdataclay/dsjava:$DEFAULT_TAG bscdataclay/dsjava:$DEFAULT_JDK_TAG
if [ $? -ne 0 ]; then printError "bscdataclay/dsjava:$DEFAULT_TAG push failed"; exit 1; fi
DOCKER_IMAGES_PUSHED+=(bscdataclay/dsjava:$DEFAULT_TAG) 

docker buildx imagetools create --tag bscdataclay/dspython:$DEFAULT_TAG bscdataclay/dspython:$DEFAULT_PY_TAG
if [ $? -ne 0 ]; then printError "bscdataclay/dspython:$DEFAULT_TAG push failed"; exit 1; fi
DOCKER_IMAGES_PUSHED+=(bscdataclay/dspython:$DEFAULT_TAG) 

##### TAG LATEST #####

docker buildx imagetools create --tag bscdataclay/base bscdataclay/base:$DEFAULT_TAG
if [ $? -ne 0 ]; then printError "bscdataclay/base:$DEFAULT_TAG push failed"; exit 1; fi
DOCKER_IMAGES_PUSHED+=(bscdataclay/base) 

docker buildx imagetools create --tag bscdataclay/logicmodule bscdataclay/logicmodule:$DEFAULT_TAG
if [ $? -ne 0 ]; then printError "bscdataclay/logicmodule:$DEFAULT_TAG push failed"; exit 1; fi
DOCKER_IMAGES_PUSHED+=(bscdataclay/logicmodule) 

docker buildx imagetools create --tag bscdataclay/dsjava bscdataclay/dsjava:$DEFAULT_TAG
if [ $? -ne 0 ]; then printError "bscdataclay/dsjava:$DEFAULT_TAG push failed"; exit 1; fi
DOCKER_IMAGES_PUSHED+=(bscdataclay/dsjava) 

docker buildx imagetools create --tag bscdataclay/dspython bscdataclay/dspython:$DEFAULT_TAG
if [ $? -ne 0 ]; then printError "bscdataclay/dspython:$DEFAULT_TAG push failed"; exit 1; fi
DOCKER_IMAGES_PUSHED+=(bscdataclay/dspython) 

docker buildx imagetools create --tag bscdataclay/client bscdataclay/client:$DEFAULT_TAG
if [ $? -ne 0 ]; then printError "bscdataclay/dspython:client push failed"; exit 1; fi
DOCKER_IMAGES_PUSHED+=(bscdataclay/client) 

printMsg " ==== Pushing dataclay to Pypi ===== "

# Upload pyclay
pushd $SCRIPTDIR/dspython/pyclay
VIRTUAL_ENV=/tmp/venv_pyclay
echo " Creating virtual environment /tmp/venv_pyclay " 
virtualenv --python=/usr/bin/python${DEFAULT_PYTHON} $VIRTUAL_ENV
echo " Calling python installation in virtual environment $VIRTUAL_ENV " 
source $VIRTUAL_ENV/bin/activate
python3 -m pip install --upgrade setuptools wheel twine
echo " * IMPORTANT: please make sure to remove build, dist and src/dataClay.egg if permission denied * " 
echo " * IMPORTANT: please make sure libyaml-dev libpython2.7-dev python-dev python3-dev python3-pip packages are installed * " 
python3 -m pip install -r requirements.txt
python3 -m pip freeze
rm -rf dist
python3 setup.py -q clean --all install sdist bdist_wheel
if [ $? -ne 0 ]; then
	echo "ERROR: error installing pyclay"
	exit -1
fi 	
#twine upload dist/*
deactivate
popd

printMsg " ==== Pushing dataclay to Maven central repository ===== "

printMsg " ===== Done! ====="
printMsg " Push summary  "
echo "MAVEN libraries PUSHED: ${MAVEN_LIBS_PUSHED[@]}"
echo "PYPI libraries PUSHED: ${PYPI_LIBS_PUSHED[@]}"
echo "DOCKER images PUSHED: " 
for DOCKER_IMAGE in ${DOCKER_IMAGES_PUSHED[@]}; do
	echo "$DOCKER_IMAGE platforms"	
	docker buildx imagetools inspect $DOCKER_IMAGE | grep Platform
done

# Clean 
rm -f $SCRIPTDIR/logicmodule/dataclay.jar



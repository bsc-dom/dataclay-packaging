#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DATACLAY_HOME_SRC=$SCRIPTDIR
SUPPORTED_JAVA_VERSIONS=(8 11)
SUPPORTED_PYTHON_VERSIONS=(3.6)
PLATFORMS=linux/amd64,linux/arm/v7

DEFAULT_JAVA=11
DEFAULT_PYTHON=3.6

#URL_DATACLAY_MAVEN_REPO="https://github.com/bsc-ssrg/dataclay-maven.git"

################################## FUNCTIONS #############################################
trap ctrl_c INT

function ctrl_c() {
	clean
	exit -1
}

function check_docker_buildx_version { 
	printf "Checking if docker buildx is available..."
	docker buildx version 2>&1 > /dev/null
	if [ $? -ne 0 ]; then return $?; fi
	printf "OK\n"
}


function check_maven_repo {  
    DATACLAY_MAVEN_REPO=$1
    # Check repository 
	pushd $DATACLAY_MAVEN_REPO 
	URL=`git config --get remote.origin.url`
	if [ "$URL" != "$URL_DATACLAY_MAVEN_REPO" ]; then
		echo "[ERROR] Repository provided $DATACLAY_MAVEN_REPO do not refer to proper GitHub $URL_DATACLAY_MAVEN_REPO. Aborting"
		return -1
	else 
		echo "Going to install dataclay in $DATACLAY_MAVEN_REPO"
	fi
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

function build_java_dockers {

	mvn dependency:copy-dependencies -DoutputDirectory=lib
	for DATACLAY_JAVA_VERSION in ${SUPPORTED_JAVA_VERSIONS[@]}; do
		DATACLAY_MAVEN_VERSION="$(get_dataclay_java_version $DATACLAY_JAVA_VERSION)"
		DATACLAY_DOCKER_TAG="$(get_java_container_version $DATACLAY_JAVA_VERSION)"
		JAR_LOCATION=$HOME/.m2/repository/dataclay/dataclay/${DATACLAY_MAVEN_VERSION}/dataclay-${DATACLAY_MAVEN_VERSION}.jar
		
		if (("$DATACLAY_JAVA_VERSION" > "9")); then       
			EXTRAE_LD_PRELOAD=""
		else 
			EXTRAE_LD_PRELOAD=${EXTRAE_HOME}/lib/libpttrace.so
		fi
		
		cp $JAR_LOCATION dataclay.jar
		echo "Building image named bscdataclay/logicmodule:$DATACLAY_DOCKER_TAG"

		if [ "$PUSH_DOCKERS" = true ] ; then
			DOCKER_IMAGES_PUSHED+=(bscdataclay/logicmodule:$DATACLAY_DOCKER_TAG)
			docker buildx build --build-arg DATACLAY_SERVICE="dataclay.logic.server.LogicModuleSrv" \
				--build-arg DATACLAY_JAVA_VERSION=$DATACLAY_JAVA_VERSION \
				--build-arg DATACLAY_MAVEN_VERSION=$DATACLAY_MAVEN_VERSION \
				--build-arg EXTRAE_LD_PRELOAD=$EXTRAE_LD_PRELOAD \
				--build-arg EXTRAE_HOME=$EXTRAE_HOME \
				-t bscdataclay/logicmodule:$DATACLAY_DOCKER_TAG --platform $PLATFORMS --push .
		else 
			docker build --build-arg DATACLAY_SERVICE="dataclay.logic.server.LogicModuleSrv" \
				--build-arg DATACLAY_JAVA_VERSION=$DATACLAY_JAVA_VERSION \
				--build-arg DATACLAY_MAVEN_VERSION=$DATACLAY_MAVEN_VERSION \
				--build-arg EXTRAE_LD_PRELOAD=$EXTRAE_LD_PRELOAD \
				--build-arg EXTRAE_HOME=$EXTRAE_HOME \
				-t bscdataclay/logicmodule:$DATACLAY_DOCKER_TAG .
		fi
		if [ $? -ne 0 ]; then
			echo "** bscdataclay/logicmodule:$DATACLAY_DOCKER_TAG BUILD FAILED! **"
			return -1
		fi

		echo "************* bscdataclay/logicmodule:$DATACLAY_DOCKER_TAG IMAGE DONE! *************"
	  	echo "Building image named bscdataclay/dsjava:$DATACLAY_DOCKER_TAG"
	  	
	  	if [ "$PUSH_DOCKERS" = true ] ; then
			docker buildx build --build-arg DATACLAY_SERVICE="dataclay.dataservice.server.DataServiceSrv" \
				--build-arg DATACLAY_JAVA_VERSION=$DATACLAY_JAVA_VERSION \
				--build-arg DATACLAY_MAVEN_VERSION=$DATACLAY_MAVEN_VERSION \
				--build-arg EXTRAE_LD_PRELOAD=$EXTRAE_LD_PRELOAD \
				--build-arg EXTRAE_HOME=$EXTRAE_HOME \				
				-t bscdataclay/dsjava:$DATACLAY_DOCKER_TAG --platform $PLATFORMS --push .
		else
			docker build --build-arg DATACLAY_SERVICE="dataclay.dataservice.server.DataServiceSrv" \
				--build-arg DATACLAY_JAVA_VERSION=$DATACLAY_JAVA_VERSION \
				--build-arg DATACLAY_MAVEN_VERSION=$DATACLAY_MAVEN_VERSION \
				--build-arg EXTRAE_LD_PRELOAD=$EXTRAE_LD_PRELOAD \
				--build-arg EXTRAE_HOME=$EXTRAE_HOME \
				-t bscdataclay/dsjava:$DATACLAY_DOCKER_TAG .
		fi	
		
		if [ $? -ne 0 ]; then
			echo "** bscdataclay/dsjava:$DATACLAY_DOCKER_TAG BUILD FAILED! **"
			return -1
		fi
		echo "************* bscdataclay/dsjava:$DATACLAY_DOCKER_TAG DataService DONE! *************"
		DOCKER_IMAGES_BUILD+=(bscdataclay/logicmodule:$DATACLAY_DOCKER_TAG)
		DOCKER_IMAGES_BUILD+=(bscdataclay/dsjava:$DATACLAY_DOCKER_TAG)
	done
	
}

function build_python_dockers {

	DATACLAY_JAVA_DOCKER_TAG="$(get_java_container_version $DEFAULT_JAVA)"

	for PYVER in ${SUPPORTED_PYTHON_VERSIONS[@]}; do
		DATACLAY_DOCKER_TAG="$(get_python_container_version $PYVER)"
		PYCLAY_VERSION="$(get_pyclay_version)"
		PYVER_WITHOUT_SUBVERSION=$PYVER
		## Get python version without subversion to install it in some packages
		PYVER_WITHOUT_SUBVERSION=$(echo $PYVER | awk -F '.' '{print $1}')
		if [ $PYVER_WITHOUT_SUBVERSION -eq "2" ]; then 
			PYVER_WITHOUT_SUBVERSION=""
		fi 
		
		echo "Building image named bscdataclay/dspython:$DATACLAY_DOCKER_TAG"
		pushd $DATACLAY_HOME_SRC/pyclay
		
		if [ -f setup.py.orig ]; then mv setup.py.orig setup.py; fi # sanity check
		cp setup.py setup.py.orig
		sed -i "s/trunk/${PYCLAY_VERSION}/g" setup.py

		if [ "$PUSH_DOCKERS" = true ] ; then
			DOCKER_IMAGES_PUSHED+=(bscdataclay/dspython:${DATACLAY_DOCKER_TAG})
			docker buildx build --build-arg DATACLAY_PYVER="$PYVER" \
				--build-arg DATACLAY_JAVA_DOCKER_TAG=$DATACLAY_JAVA_DOCKER_TAG \
				-t bscdataclay/dspython:$DATACLAY_DOCKER_TAG --platform $PLATFORMS --push .
		else 
			docker build --build-arg DATACLAY_PYVER="$PYVER" \
				--build-arg DATACLAY_JAVA_DOCKER_TAG=$DATACLAY_JAVA_DOCKER_TAG \
				--build-arg PYTHON_PIP_VERSION=$PYVER_WITHOUT_SUBVERSION \
				-t bscdataclay/dspython:$DATACLAY_DOCKER_TAG .
		fi
		
		if [ $? -ne 0 ]; then
			echo "** bscdataclay/dspython:$DATACLAY_DOCKER_TAG BUILD FAILED! **"
	   	 	mv setup.py.orig setup.py
			return -1
		fi
	    mv setup.py.orig setup.py
	    popd
	    
		DOCKER_IMAGES_BUILD+=(bscdataclay/dspython:${DATACLAY_DOCKER_TAG})
	done

}

function install_local_maven_jar { 
	for DATACLAY_JAVA_VERSION in ${SUPPORTED_JAVA_VERSIONS[@]}; do	
		export DATACLAY_MAVEN_VERSION="$(get_dataclay_java_version $DATACLAY_JAVA_VERSION)"
		echo " -------------------------< Installing dataclay:dataclay:$DATACLAY_MAVEN_VERSION >-------------------------- "
		mvn clean install -Dmaven.test.skip=true -P java-$DATACLAY_JAVA_VERSION
		echo " ----------------------------------------------------------------------------------------------------------- "
		MAVEN_LIBS_BUILD+=(dataclay${DATACLAY_MAVEN_VERSION}.jar)
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



function pypi_push { 
	export PYCLAY_VERSION="$(get_pypi_version)"
	
	PYTHON_VER=$1
	
	VIRTUAL_ENV=$SCRIPTDIR/pyclay/.pyenv${PYTHON_VER}
	if [ ! -d "${VIRTUAL_ENV}" ]; then
		echo " Creating virtual environment $VIRTUAL_ENV " 
		virtualenv --python=/usr/bin/python${PYTHON_VER} $VIRTUAL_ENV
	fi
	echo " Calling python installation in virtual environment $VIRTUAL_ENV " 
	source $VIRTUAL_ENV/bin/activate
	pip install wheel
	echo " * IMPORTANT: please make sure to remove build, dist and src/dataClay.egg if permission denied * " 
	echo " * IMPORTANT: please make sure libyaml-dev libpython2.7-dev python-dev python3-dev python3-pip packages are installed * " 
	python setup.py -q clean --all install || { echo 'installation of pyclay failed' ; deactivate; return -1; } 
	if [ $? -ne 0 ]; then
		echo "ERROR: error installing pyclay"
		return -1
	fi 	
	pip freeze
	deactivate
	PYPI_LIBS+=("dataclay==$PYCLAY_VERSION")
	
	pushd pyclay
	# replace 
	rm -rf dist
	python setup.py sdist bdist_wheel
	twine upload dist/*
 #--repository-url https://test.pypi.org/legacy/
}

function maven_push { 
	for JAVA_VERSION in ${SUPPORTED_JAVA_VERSIONS[@]}; do
		DATACLAY_MAVEN_VERSION="$(get_dataclay_java_version $JAVA_VERSION)"
		echo " ===== Installing dataclay $DATACLAY_MAVEN_VERSION in  $DATACLAY_MAVEN_REPO ====="
		JAR_LOCATION=$HOME/.m2/repository/dataclay/dataclay/${DATACLAY_MAVEN_VERSION}/dataclay-${DATACLAY_MAVEN_VERSION}.jar
		POM_LOCATION=$HOME/.m2/repository/dataclay/dataclay/${DATACLAY_MAVEN_VERSION}/dataclay-${DATACLAY_MAVEN_VERSION}.pom
		
		mvn install:install-file \
			   -Dfile=$JAR_LOCATION \
			   -DgroupId=dataclay \
			   -DartifactId=dataclay \
			   -Dversion=$DATACLAY_MAVEN_VERSION \
			   -Dpackaging=jar \
			   -DlocalRepositoryPath=$DATACLAY_MAVEN_REPO \
			   -DpomFile=$POM_LOCATION \
			   -DcreateChecksum=true
		MAVEN_LIBS_PUSHED+=(dataclay${DATACLAY_MAVEN_VERSION}.jar)
			   
	done
	echo " ===== Pushing  dataclay $DATACLAY_MAVEN_VERSION into Maven ====="
	
	pushd $DATACLAY_MAVEN_REPO		
	git add -A .
	git commit -m "Uploading dataclay maven $DATACLAY_MAVEN_VERSION " 
	git push origin repository
	popd
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
 | (_| | (_| | || (_| | |____| | (_| | |_| |  release script
  \__,_|\__,_|\__\__,_|\_____|_|\__,_|\__, |
                                       __/ |
                                      |___/ 
'"'"
echo " Welcome to dataClay release script! "

echo " *** Checking requirements ... *** "
./check_requirements.sh
prepare_docker_builder
echo " *** Requirements accomplished :) *** "

################################## VERSIONS #############################################

DATACLAY_RELEASE_VERSION=2.0
DATACLAY_DEVELOPMENT_VERSION="-1"
DATACLAY_SNAPSHOT_VERSION="-1"

read -p "Enter dataClay version [$DATACLAY_RELEASE_VERSION]: " dataclay_version
DATACLAY_RELEASE_VERSION=${dataclay_version:-$DATACLAY_RELEASE_VERSION}

read -p "Enter dataClay DEVELOPMENT version or -1 if it's a release [$DATACLAY_DEVELOPMENT_VERSION]: " dataclay_version
DATACLAY_DEVELOPMENT_VERSION=${dataclay_version:-$DATACLAY_DEVELOPMENT_VERSION}

echo "In a continuous integration environment, version plays a vital role in keeping the integration build 
up-to-date while minimizing the amount of rebuilding that is required for each integration step. 

In maven this means that we will push dataclay version $(get_maven_version)-SNAPSHOT
In pypi this means that we will push dataclay library into testPypi repository with version: $(get_pypi_version)
In dockers this means that we will push dataclay versions like $(get_container_version jdk$JAVA_VERSION)-SNAPSHOT
 
"
read -p "Do you wish to use it as a ?" yn
case $yn in
	[Yy]* ) make install; break;;
	[Nn]* ) exit;;
	* ) echo "Please answer yes or no.";;
esac
    
################################## PREPARE #############################################


echo " -- I'm going to push following jar into maven using repository $MAVEN_REPOSITORY: dataclay-$(get_maven_version).jar "
echo " -- I'm going to push python libraries into pypi: dataclay==$(get_pypi_version) "
echo " -- I'm going to push into DockerHub docker images: "
echo "                bscdataclay/logicmodule:${DATACLAY_RELEASE_VERSION})"
echo "                bscdataclay/dsjava:${DATACLAY_RELEASE_VERSION})"
echo "                bscdataclay/dspython:${DATACLAY_RELEASE_VERSION})"
echo "                bscdataclay/client:${DATACLAY_RELEASE_VERSION})"
for JAVA_VERSION in ${SUPPORTED_JAVA_VERSIONS[@]}; do
	DATACLAY_DOCKER_TAG="$(get_container_version jdk$JAVA_VERSION)"
	echo "                bscdataclay/logicmodule:${DATACLAY_DOCKER_TAG})"
	echo "                bscdataclay/dsjava:${DATACLAY_DOCKER_TAG})"
done
for PYTHON_VERSION in ${SUPPORTED_PYTHON_VERSIONS[@]}; do
	DATACLAY_DOCKER_TAG="$(get_container_version py$PYTHON_VERSION)"
	echo "                bscdataclay/dspython:${DATACLAY_DOCKER_TAG})"
done

exit -1

################################## PUSH #############################################

echo " ===== Pushing dataclay $DATACLAY_MAVEN_VERSION into Maven ====="
#maven_push

echo " ===== Pushing  dataclay into Pypi ====="
# pypi_push

DEFAULT_TAG="$(get_container_version)"
DEFAULT_JDK_TAG="$(get_container_version jdk$DEFAULT_JAVA)"
DEFAULT_PY_TAG="$(get_container_version py$DEFAULT_PYTHON)"

# BASE IMAGES 
pushd $SCRIPTDIR/base
for JAVA_VERSION in ${SUPPORTED_JAVA_VERSIONS[@]}; do
	BASE_VERSION_TAG="$(get_container_version jdk$JAVA_VERSION)"
	echo "************* Pushing image named bscdataclay/base:$BASE_VERSION_TAG *************"
	docker buildx build --build-arg JDK=$JAVA_VERSION -t bscdataclay/base:$BASE_VERSION_TAG --platform $PLATFORMS --push .
	echo "************* bscdataclay/base:$BASE_VERSION_TAG IMAGE PUSHED! *************" 
done
popd

# LOGICMODULE
pushd $SCRIPTDIR/logicmodule
for JAVA_VERSION in ${SUPPORTED_JAVA_VERSIONS[@]}; do
	VERSION="$(get_container_version jdk$JAVA_VERSION)"
	echo "************* Pushing image named bscdataclay/logicmodule:$JAVACLAY_TAG *************"
	docker buildx build --build-arg BASE_VERSION=$VERSION -t bscdataclay/logicmodule:$VERSION --platform $PLATFORMS --push .
	echo "************* bscdataclay/logicmodule:$JAVACLAY_TAG IMAGE PUSHED! *************"
done
popd 

# DSJAVA
pushd $SCRIPTDIR/dsjava
for JAVA_VERSION in ${SUPPORTED_JAVA_VERSIONS[@]}; do
	VERSION="$(get_container_version jdk$JAVA_VERSION)"
	echo "************* Building image named bscdataclay/dsjava:$JAVACLAY_TAG *************"
	docker buildx build --build-arg LOGICMODULE_VERSION=$VERSION -t bscdataclay/dsjava:$VERSION --platform $PLATFORMS --push .
	echo "************* bscdataclay/dsjava:$JAVACLAY_TAG DONE! *************"
done
popd 

# DSPYTHON
pushd $SCRIPTDIR/dspython
for PYTHON_VERSION in ${SUPPORTED_PYTHON_VERSIONS[@]}; do
	BASE_VERSION="$(get_container_version jdk$DEFAULT_JAVA)"
	VERSION="$(get_container_version py$PYTHON_VERSION)"
	# Get python version without subversion to install it in some packages
	PYTHON_PIP_VERSION=$PYTHON_VERSION
	PYTHON_PIP_VERSION=$(echo $PYTHON_VERSION | awk -F '.' '{print $1}')
	if [ $PYTHON_PIP_VERSION -eq "2" ]; then 
		PYTHON_PIP_VERSION=""
	fi 
	echo "************* Building image named bscdataclay/dspython:$PYCLAY_TAG python version $DEFAULT_PYTHON and pip version $PYTHON_PIP_VERSION *************"
	docker buildx build --build-arg BASE_VERSION=$BASE_VERSION \
				 --build-arg DATACLAY_PYVER=$PYTHON_VERSION \
				 --build-arg PYTHON_PIP_VERSION=$PYTHON_PIP_VERSION -t bscdataclay/dspython:$VERSION --platform $PLATFORMS --push .
	echo "************* bscdataclay/dspython:$PYCLAY_TAG DONE! *************"
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
			 -t bscdataclay/client:$CLIENT_TAG --platform $PLATFORMS --push .
echo "************* bscdataclay/client:$CLIENT_TAG DONE! *************"
popd 


## Tag default versions 
docker tag bscdataclay/base:$DEFAULT_JDK_TAG bscdataclay/base:$DEFAULT_TAG
docker tag bscdataclay/logicmodule:$DEFAULT_JDK_TAG bscdataclay/logicmodule:$DEFAULT_TAG
docker tag bscdataclay/dsjava:$DEFAULT_JDK_TAG bscdataclay/dsjava:$DEFAULT_TAG
docker tag bscdataclay/dspython:$DEFAULT_PY_TAG bscdataclay/dspython:$DEFAULT_TAG

# Clean
clean

echo " ===== Done! ====="
echo " ################### Build summary ############################# "
echo "MAVEN libraries BUILD: ${MAVEN_LIBS_BUILD[@]}"
echo "PYPI libraries BUILD: ${PYPI_LIBS_BUILD[@]}"
echo "DOCKER images BUILD: ${DOCKER_IMAGES_BUILD[@]}" 

echo " ################### Pushed summary ############################# "
echo "MAVEN libraries PUSHED: ${MAVEN_LIBS_PUSHED[@]}"
echo "PYPI libraries PUSHED: ${PYPI_LIBS_PUSHED[@]}"
echo "DOCKER images PUSHED: " 
for DOCKER_IMAGE in ${DOCKER_IMAGES_PUSHED[@]}; do
	echo "$DOCKER_IMAGE platforms"	
	docker buildx imagetools inspect $DOCKER_IMAGE | grep Platform
done


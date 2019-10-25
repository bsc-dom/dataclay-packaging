#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DATACLAY_HOME_SRC=$SCRIPTDIR
URL_DATACLAY_MAVEN_REPO="https://github.com/bsc-ssrg/dataclay-maven.git"
SUPPORTED_JAVA_VERSIONS=(8 11)
SUPPORTED_PYTHON_VERSIONS=(2.7 3.6)
PLATFORMS=linux/amd64,linux/arm/v7
# Unsupported platforms in openjdk or python dockerhub cannot be supported here
INSTALLED_REQUIREMENTS=("mvn" "java" "javac" "python" "docker")
REQUIRED_JAVA_VERSION=11
REQUIRED_DOCKER_VERSION=19
DEFAULT_JAVA=8
DEFAULT_PYTHON=3.6
RED="\033[0;31m"
NOCOLOR="\033[0m"
GREEN="\033[0;32m"
# Extrae home in dockers (needed outside to configure LD preload on demand)
EXTRAE_HOME=/usr/src/extrae

################################## WINDOWS #############################################

if [[ "$OSTYPE" == "cygwin" ]]; then
        # POSIX compatibility layer and Linux environment emulation for Windows
        SCRIPTDIR=$(echo "$SCRIPTDIR" | sed -e 's/^\///' -e 's/\//\\/g' -e 's/^./\0:/')
elif [[ "$OSTYPE" == "msys" ]]; then
        # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
        SCRIPTDIR=$(echo "$SCRIPTDIR" | sed -e 's/^\///' -e 's/\//\\/g' -e 's/^./\0:/')
elif [[ "$OSTYPE" == "win32" ]]; then
        # I'm not sure this can happen.
        SCRIPTDIR=$(echo "$SCRIPTDIR" | sed -e 's/^\///' -e 's/\//\\/g' -e 's/^./\0:/')
fi
################################## FUNCTIONS #############################################
trap ctrl_c INT

function ctrl_c() {
	clean
	exit -1
}

function usage {
	FORMAT="%-30s %-30s \n"
	echo ""
	echo " Usage: $0 [options] "
	echo ""
	echo ""
	echo "Options:"
	printf "$FORMAT" "--build-jar"	"Indicates to build dataclay JAR: this will create a jar called dataclay.jar in current directory."
	printf "$FORMAT" "--build-pyclay"	"Indicates to build pyclay "
	printf "$FORMAT" "" "NOTE: Python virtual environment will be created (if needed) in pyclay/.pyenv<pythonversion>"
	printf "$FORMAT" "--build-dockers"	"Indicates to build docker images for local usage."
	printf "$FORMAT" "--push-dockers"	"Push dataclay to DockerHub. The docker will be build before pushing, to just build it for local usage use --build-dockers. USE IT CAREFULLY."
	printf "$FORMAT" "--push-maven <dataclay-maven local repository>"	"Push dataclay to Maven. The jar will be build before pushing. To just build the jar, use --build-jar. USE IT CAREFULLY."
	printf "$FORMAT" "--push-pypi"	"Push dataclay to Pypi. Pyclay will be build before pushing. To just install it in pyclay/.pyenv, use --build-pyclay. USE CAREFULLY."
	printf "$FORMAT" "--push-all-debug <dataclay-maven-repo>"	"Push dataclay to DockerHub and Maven EXCEPT pypi, used for testing reasons."
	printf "$FORMAT" "" "USE CAREFULLY. Reason: Pypi do not allow you to replace a version once is published."
	printf "$FORMAT" "--push-all <dataclay-maven-repo>"	"Push dataclay to DockerHub, Maven and Pypi."
	printf "$FORMAT" "" "USE CAREFULLY."
	printf "$FORMAT" "" "Remember to clone in local repository folder: $URL_DATACLAY_MAVEN_REPO "
	printf "$FORMAT" "--final-release"	"Indicates release is not a pre-release"
	
}

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

function python_setup {  
	PYTHON_VER=$1
	export PYCLAY_VERSION="$(get_pyclay_version)"
	
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
			echo "ERROR: missing support for $i in buildx builder"
			return -1
		fi
		printf "OK\n"
		
	done
	
}

function build_java_client_docker {
	for DATACLAY_JAVA_VERSION in ${SUPPORTED_JAVA_VERSIONS[@]}; do
		DATACLAY_JAVA_DOCKER_TAG="$(get_java_container_version $DATACLAY_JAVA_VERSION)"
		DATACLAY_DOCKER_TAG=$DATACLAY_JAVA_DOCKER_TAG
		echo "Building image named bscdataclay/client:$DATACLAY_DOCKER_TAG"
		if [ "$PUSH_DOCKERS" = true ] ; then
			DOCKER_IMAGES_PUSHED+=(bscdataclay/client:$DATACLAY_DOCKER_TAG)
			docker buildx build -f client.Dockerfile \
				--build-arg DATACLAY_JAVA_DOCKER_TAG=$DATACLAY_JAVA_DOCKER_TAG \
				-t bscdataclay/client:$DATACLAY_DOCKER_TAG --platform $PLATFORMS --push .
		else
			docker build -f client.Dockerfile \
				--build-arg DATACLAY_JAVA_DOCKER_TAG=$DATACLAY_JAVA_DOCKER_TAG \
				-t bscdataclay/client:$DATACLAY_DOCKER_TAG .			
		fi
		
		if [ $? -ne 0 ]; then
			echo "** bscdataclay/client:$DATACLAY_DOCKER_TAG BUILD FAILED! **"
			return -1
		fi
	
		DOCKER_IMAGES_BUILD+=(bscdataclay/client:$DATACLAY_DOCKER_TAG)
	done
}

function build_python_client_docker {
	pushd pyclay
	for PYVER in ${SUPPORTED_PYTHON_VERSIONS[@]}; do
		
		DATACLAY_PYCLAY_DOCKER_TAG="$(get_python_container_version $PYVER)"
		DATACLAY_DOCKER_TAG=$DATACLAY_PYCLAY_DOCKER_TAG
		echo "Building image named bscdataclay/client:$DATACLAY_DOCKER_TAG"
		if [ "$PUSH_DOCKERS" = true ] ; then
			DOCKER_IMAGES_PUSHED+=(bscdataclay/client:$DATACLAY_DOCKER_TAG)
			docker buildx build -f client.Dockerfile \
				--build-arg DATACLAY_PYCLAY_DOCKER_TAG=$DATACLAY_PYCLAY_DOCKER_TAG \
				-t bscdataclay/client:$DATACLAY_DOCKER_TAG --platform $PLATFORMS --push .
		else
			docker build -f client.Dockerfile \
				--build-arg DATACLAY_PYCLAY_DOCKER_TAG=$DATACLAY_PYCLAY_DOCKER_TAG \
				-t bscdataclay/client:$DATACLAY_DOCKER_TAG .			
		fi
		
		if [ $? -ne 0 ]; then
			echo "** bscdataclay/client:$DATACLAY_DOCKER_TAG BUILD FAILED! **"
			return -1
		fi
	
		DOCKER_IMAGES_BUILD+=(bscdataclay/client:$DATACLAY_DOCKER_TAG)
		
	done	
	popd

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

function get_dataclay_java_version { 
	DATACLAY_JAVA_VERSION=$1
	if [ "$DATACLAY_DEVELOPMENT_VERSION" != "-1" ] ; then
		DATACLAY_MAVEN_VERSION="${DATACLAY_RELEASE_VERSION}.${DATACLAY_JAVA_VERSION}-beta-${DATACLAY_DEVELOPMENT_VERSION}"
	else 
		DATACLAY_MAVEN_VERSION="$DATACLAY_RELEASE_VERSION.${DATACLAY_JAVA_VERSION}"
	fi 
	echo $DATACLAY_MAVEN_VERSION
}

function get_pyclay_version { 
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



function pypi_push { 
	export PYCLAY_VERSION="$(get_pyclay_version)"
	pushd pyclay
	# replace 
	if [ -f setup.py.orig ]; then mv setup.py.orig setup.py; fi # sanity check
	cp setup.py setup.py.orig
	sed -i "s/trunk/${PYCLAY_VERSION}/g" setup.py
	rm -rf dist
	python setup.py sdist bdist_wheel
	twine upload dist/*
	mv setup.py.orig setup.py
	popd
	
	PYPI_LIBS_PUSHED+=(${PYCLAY_VERSION})	
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

function clean() { 
	printf "Cleaning..."
	if [ -f $SCRIPTDIR/pom.xml.orig ]; then 
		mv $SCRIPTDIR/pom.xml.orig $SCRIPTDIR/pom.xml # sanity check if script was interrupted 
	fi
	rm -f $SCRIPTDIR/pom.xml.orig
	
	if [ -f $SCRIPTDIR/pyclay/setup.py.orig ]; then 
		mv $SCRIPTDIR/pyclay/setup.py.orig $SCRIPTDIR/pyclay/setup.py
	fi
	
	#rm -f dataclay.jar
	printf "OK\n"
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
 | (_| | (_| | || (_| | |____| | (_| | |_| |  RELEASE SCRIPT 2019
  \__,_|\__,_|\__\__,_|\_____|_|\__,_|\__, |
                                       __/ |
                                      |___/ 
'"'"
echo " Welcome to dataClay release script! This script is intended to: "
echo "		- Build dataClay and install in local maven repository"
echo "		- Build pyClay and install in virtual environment"
echo "		- Build new docker images of dataClay "
echo "		- If push option selected: Publish dataClay in DockerHub, Maven or Pypi"
echo ""
if [[ $# -lt 1 ]]; then
	echo " WARNING: You did not provide any argument!"
	usage
	exit -1
fi

# Check parameters
BUILD_JAR=false
BUILD_PYCLAY=false
BUILD_DOCKERS=false

PUSH_DOCKERS=false
PUSH_MAVEN=false
PUSH_PYPI=false
FINAL_RELEASE=false 

DATACLAY_MAVEN_REPO=""

################################## OPTIONS #############################################
while [[ $# -gt 0 ]]; do
    key="$1"
	case $key in
	--push-all)
		shift
    	if [[ $# -ne 1 ]]; then 
    		usage
    		exit -1
    	fi
    	check_maven_repo $1
    	DATACLAY_MAVEN_REPO=$1
        BUILD_JAR=true
    	BUILD_DOCKERS=true
        BUILD_PYCLAY=true
        # push
		PUSH_MAVEN=true
		PUSH_DOCKERS=true
		PUSH_PYPI=true
		shift
        ;;
	--push-all-debug)
		shift
    	if [[ $# -ne 1 ]]; then 
    		usage
    		exit -1
    	fi
    	check_maven_repo $1
    	DATACLAY_MAVEN_REPO=$1
        
        BUILD_JAR=true
    	BUILD_DOCKERS=true
        BUILD_PYCLAY=false
		PUSH_MAVEN=true
		PUSH_DOCKERS=true
		PUSH_PYPI=false
		shift
		;;
    --push-maven)
    	shift 
    	if [[ $# -ne 1 ]]; then 
    		usage
    		exit -1
    	fi
    	check_maven_repo $1
    	DATACLAY_MAVEN_REPO=$1
        BUILD_JAR=true
		PUSH_MAVEN=true
    	shift
        ;;
    --push-dockers)
    	BUILD_DOCKERS=true
    	PUSH_DOCKERS=true
    	shift
        ;;  
    --push-pypi)
        BUILD_PYCLAY=true
    	PUSH_PYPI=true
    	shift
        ;;
    --build-all)
        # local builds
        BUILD_JAR=true
        BUILD_PYCLAY=true
        BUILD_DOCKERS=true 
		shift
        ;;
    --build-jar) 
   		BUILD_JAR=true
   		shift
   		;; 
   	--build-pyclay)
      	BUILD_PYCLAY=true
   		shift
   		;; 
   	--build-dockers)
    	BUILD_JAR=true 
      	BUILD_PYCLAY=true 
   		BUILD_DOCKERS=true
   		
   		shift
   		;;
	--final-release) 
		JAR_SUFFIX="$DATACLAY_MAVEN_VERSION"
		FINAL_RELEASE=true
		shift
        ;;
    -h|--help)
        usage
        exit 0
        ;;
    *)
        echo "  ERROR: Bad option $key"
        shift
        usage   # unknown option
        exit 1
        ;;
    esac
done



echo " *** Checking requirements ... *** "
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
echo " *** Requirements accomplished :) *** "

################################## PREPARE #############################################

DATACLAY_RELEASE_VERSION=2.0
DATACLAY_DEVELOPMENT_VERSION="-1"
read -p "Enter dataClay version [$DATACLAY_RELEASE_VERSION]: " dataclay_version
DATACLAY_RELEASE_VERSION=${dataclay_version:-$DATACLAY_RELEASE_VERSION}
if [ "$FINAL_RELEASE" = false ] ; then
	read -p "Enter dataClay development version: " dataclay_dev_version
	DATACLAY_DEVELOPMENT_VERSION=${dataclay_dev_version:-$DATACLAY_DEVELOPMENT_VERSION}
fi

declare -a MAVEN_LIBS
declare -a PYPI_LIBS
declare -a DOCKER_IMAGES
for JAVA_VERSION in ${SUPPORTED_JAVA_VERSIONS[@]}; do
	MAVEN_LIBS+=(dataclay$(get_dataclay_java_version $JAVA_VERSION).jar)
	DATACLAY_DOCKER_TAG="$(get_java_container_version $JAVA_VERSION)"
	DOCKER_IMAGES+=(bscdataclay/logicmodule:${DATACLAY_DOCKER_TAG})
	DOCKER_IMAGES+=(bscdataclay/dsjava:${DATACLAY_DOCKER_TAG})
	DOCKER_IMAGES+=(bscdataclay/client:${DATACLAY_DOCKER_TAG})
done
for PYTHON_VERSION in ${SUPPORTED_PYTHON_VERSIONS[@]}; do
	DATACLAY_DOCKER_TAG="$(get_python_container_version $PYTHON_VERSION)"
	DOCKER_IMAGES+=(bscdataclay/dspython:${DATACLAY_DOCKER_TAG})
	DOCKER_IMAGES+=(bscdataclay/client:${DATACLAY_DOCKER_TAG})
done
PYPI_LIBS+=("dataclay=="$(get_pyclay_version))

echo " ----------------------------------------------------------------------------------------------------------- "
if [ "$BUILD_JAR" = true ] ; then
	echo " -- I'm going to build and install in local maven repository: ${MAVEN_LIBS[@]} "
fi
if [ "$BUILD_PYCLAY" = true ] ; then
	echo " -- I'm going to build pyclay libraries: ${PYPI_LIBS[@]} "
fi 
if [ "$BUILD_DOCKERS" = true ] ; then
	echo " -- I'm going to build docker images: ${DOCKER_IMAGES[@]} "
	echo " 
										***** WARNING *****
			If it's the first time you are building the dockers it may take LONG time (aprox. 2 hours!!!) 
			due to ARM python requirements that must be compiled (grpcio and numpy) 
			Next times, using same buildx builder (named dataclaybuilder) it will take much less.
										*******************
	"
fi
if [ "$PUSH_MAVEN" = true ] ; then
	echo " -- I'm going to push following jars into maven using repository $MAVEN_REPOSITORY: ${MAVEN_LIBS[@]} "
fi
if [ "$PUSH_PYPI" = true ] ; then
	echo " -- I'm going to push python libraries into pypi: ${PYPI_LIBS[@]} "
fi
if [ "$PUSH_DOCKERS" = true ] ; then
	echo " -- I'm going to push into DockerHub docker images: ${DOCKER_IMAGES[@]} "
fi
echo " ----------------------------------------------------------------------------------------------------------- "

declare -a MAVEN_LIBS_BUILD
declare -a PYPI_LIBS_BUILD
declare -a DOCKER_IMAGES_BUILD
declare -a MAVEN_LIBS_PUSHED
declare -a PYPI_LIBS_PUSHED
declare -a DOCKER_IMAGES_PUSHED
################################## BUILD #############################################


pushd $SCRIPTDIR
if [ "$BUILD_JAR" = true ] ; then
	# Building dataclay 
	install_local_maven_jar $JAVA_VERSION
	if [ $? -ne 0 ]; then clean; exit $?; fi	
fi 


if [ "$BUILD_PYCLAY" = true ] ; then	
	pushd $SCRIPTDIR/pyclay
	for PYTHON_VERSION in ${SUPPORTED_PYTHON_VERSIONS[@]}; do
		python_setup $PYTHON_VERSION
		if [ $? -ne 0 ]; then clean; exit $?; fi
	done
	popd
fi

if [ "$BUILD_DOCKERS" = true ]; then	
	build_java_dockers $JAVA_VERSION
	if [ $? -ne 0 ]; then clean; exit $?; fi
	build_python_dockers $PYTHON_VERSION
	if [ $? -ne 0 ]; then clean; exit $?; fi
	build_java_client_docker
	if [ $? -ne 0 ]; then clean; exit $?; fi
	build_python_client_docker
	if [ $? -ne 0 ]; then clean; exit $?; fi
fi


################################## PUSH #############################################
if [ "$PUSH_DOCKERS" = false ] ; then
	# push dockers implies build dockers (buildx will push them)
	echo " ===== NOT Pushing any docker into DockerHub ====="
fi
popd

if [ "$PUSH_MAVEN" = true ] ; then
	echo " ===== Pushing dataclay $DATACLAY_MAVEN_VERSION into Maven ====="
	maven_push
	if [ $? -ne 0 ]; then clean; exit $?; fi
else 
	echo " ===== NOT Pushing into Maven ====="
fi

pushd $SCRIPTDIR
if [ "$PUSH_PYPI" = true ] ; then
	echo " ===== Pushing  dataclay into Pypi ====="
	pypi_push
	if [ $? -ne 0 ]; then clean; exit $?; fi
else 
	echo " ===== NOT Pushing dataclay into Pypi ====="	
fi
popd

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


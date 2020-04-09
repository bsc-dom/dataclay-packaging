#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
grn=$'\e[1;32m'; blu=$'\e[1;34m'; red=$'\e[1;91m'; end=$'\e[0m';
function printMsg { echo "${blu}[$(basename $0)] $1 ${end}"; }
function printError { echo "${red}======== $1 ========${end}"; }
set -e

#=== FUNCTION ================================================================
# NAME: singularity_build
# DESCRIPTION: Build singularity image and store in singularity/ folder
#=============================================================================
function singularity_build { 
	IMAGE_NAME=$1
	TAG=$2
	DOCKER_IMAGE="${DOCKER_REPOSITORY}\/${IMAGE_NAME}:${TAG}"
	SINGULARITY_IMAGE_NAME=${IMAGE_NAME}.${TAG}
	
	printMsg "Building image to $REPOSITORY/${SINGULARITY_IMAGE_NAME}.sif from $DOCKER_IMAGE"
	tmpfile=$(mktemp /tmp/singularity-templateXXXXXX.recipe)
	sed "s/DOCKER_IMAGE/$DOCKER_IMAGE/g" $SINGULARITY_TEMPLATE >> $tmpfile
	#SINGULARITY_IMAGE_NAME="${SINGULARITY_IMAGE_NAME//./-}"
	singularity build --force --remote $REPOSITORY/${SINGULARITY_IMAGE_NAME}.sif $tmpfile
	rm $tmpfile
	printMsg "$REPOSITORY/${IMAGE_NAME}.sif created!" 
}

################################## OPTIONS #############################################
DEV=false
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
 | (_| | (_| | || (_| | |____| | (_| | |_| |  SINGULARITY build script
  \__,_|\__,_|\__\__,_|\_____|_|\__,_|\__, |
                                       __/ |
                                      |___/ 
'"'"
printMsg " Welcome to dataClay build script!"


DOCKER_REPOSITORY="bscdataclay"
REPOSITORY=$SCRIPTDIR/singularity
source $SCRIPTDIR/config.sh

################################## BUILD #############################################
SINGULARITY_TEMPLATE=$SCRIPTDIR/singularity/singularity-template.recipe

# LOGICMODULE
pushd $SCRIPTDIR/logicmodule
for JAVA_VERSION in ${!JAVA_CONTAINER_VERSIONS[@]}; do
	VERSION="${JAVA_CONTAINER_VERSIONS[$JAVA_VERSION]}"
	singularity_build logicmodule $VERSION
done
popd 

# DSJAVA
pushd $SCRIPTDIR/dsjava
for JAVA_VERSION in ${!JAVA_CONTAINER_VERSIONS[@]}; do
	VERSION="${JAVA_CONTAINER_VERSIONS[$JAVA_VERSION]}"
	singularity_build dsjava $VERSION
done
popd 

# DSPYTHON
pushd $SCRIPTDIR/dspython
for PYTHON_VERSION in ${!PYTHON_CONTAINER_VERSIONS[@]}; do
	VERSION="${PYTHON_CONTAINER_VERSIONS[$PYTHON_VERSION]}"
	singularity_build dspython $VERSION
done
popd 

# CLIENT 
pushd $SCRIPTDIR/client
singularity_build client $CLIENT_TAG 
popd 

## Tag default versions 
# NOTE: latest and dev are not distinguished here
rm $REPOSITORY/logicmodule.sif $REPOSITORY/dsjava.sif $REPOSITORY/dspython.sif $REPOSITORY/client.sif 
ln -s logicmodule.${DEFAULT_JDK_TAG}.sif $REPOSITORY/logicmodule.sif
ln -s dsjava.${DEFAULT_JDK_TAG}.sif $REPOSITORY/dsjava.sif
ln -s dspython.${DEFAULT_PY_TAG}.sif $REPOSITORY/dspython.sif
ln -s client.${CLIENT_TAG}.sif $REPOSITORY/client.sif 

# Check docker images 
printMsg "Generated images:"
ls -la $SCRIPTDIR/singularity | grep ".sif"

printMsg "Done!"

#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
grn=$'\e[1;32m'; blu=$'\e[1;34m'; red=$'\e[1;91m'; end=$'\e[0m';
function printMsg { echo "${blu}[$(basename $0)] $1 ${end}"; }
function printError { echo "${red}======== $1 ========${end}"; }
set -e

#=== FUNCTION ================================================================
# NAME: singularity_push
# DESCRIPTION: Push singularity image into Sylabs cloud
#=============================================================================
function singularity_push { 
	IMAGE_NAME=$1
	TAG=$2
	SINGULARITY_IMAGE_NAME=${IMAGE_NAME}.${TAG}
	printMsg "Pushing image to $REPOSITORY/${IMAGE_NAME}:${TAG} from $LOCAL_REPOSITORY/${SINGULARITY_IMAGE_NAME}.sif"
	singularity push -U $LOCAL_REPOSITORY/${SINGULARITY_IMAGE_NAME}.sif $REPOSITORY/${IMAGE_NAME}:${TAG}
	printMsg "$REPOSITORY/${IMAGE_NAME}:${TAG} pushed!" 
}

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
 | (_| | (_| | || (_| | |____| | (_| | |_| |  SINGULARITY build script
  \__,_|\__,_|\__\__,_|\_____|_|\__,_|\__, |
                                       __/ |
                                      |___/ 
'"'"
printMsg " Welcome to dataClay build script!"
LOCAL_REPOSITORY="$SCRIPTDIR/singularity"
REPOSITORY="library://support-dataclay/default"
source $SCRIPTDIR/config.sh

# LOGICMODULE
pushd $SCRIPTDIR/logicmodule
for JAVA_VERSION in ${!JAVA_CONTAINER_VERSIONS[@]}; do
	VERSION="${JAVA_CONTAINER_VERSIONS[$JAVA_VERSION]}"
	singularity_push logicmodule $VERSION
done
popd 

# DSJAVA
pushd $SCRIPTDIR/dsjava
for JAVA_VERSION in ${!JAVA_CONTAINER_VERSIONS[@]}; do
	VERSION="${JAVA_CONTAINER_VERSIONS[$JAVA_VERSION]}"
	singularity_push dsjava $VERSION
done
popd 

# DSPYTHON
pushd $SCRIPTDIR/dspython
for PYTHON_VERSION in ${!PYTHON_CONTAINER_VERSIONS[@]}; do
	VERSION="${PYTHON_CONTAINER_VERSIONS[$PYTHON_VERSION]}"
	singularity_push dspython $VERSION
done
popd 

# CLIENT 
pushd $SCRIPTDIR/client
singularity_push client $CLIENT_TAG 
popd 


## Tag default versions 
singularity push -U $LOCAL_REPOSITORY/logicmodule.${DEFAULT_JDK_TAG}.sif $REPOSITORY/logicmodule:$DEFAULT_TAG
singularity push -U $LOCAL_REPOSITORY/dsjava.${DEFAULT_JDK_TAG}.sif $REPOSITORY/dsjava:$DEFAULT_TAG
singularity push -U $LOCAL_REPOSITORY/dspython.${DEFAULT_PY_TAG}.sif $REPOSITORY/logicmodule:$DEFAULT_PY_TAG


# Tag latest
if [ "$DEV" = false ] ; then
	singularity push -U $LOCAL_REPOSITORY/logicmodule.${DEFAULT_TAG}.sif $REPOSITORY/logicmodule:latest
	singularity push -U $LOCAL_REPOSITORY/dsjava.${DEFAULT_TAG}.sif $REPOSITORY/dsjava:latest
	singularity push -U $LOCAL_REPOSITORY/dspython.${DEFAULT_TAG}.sif $REPOSITORY/dspython:latest
	singularity push -U $LOCAL_REPOSITORY/client.${DEFAULT_TAG}.sif $REPOSITORY/client:latest
fi 

# Check docker images 
printMsg "Generated images:"
ls $SCRIPTDIR/singularity | grep "*.sif"

printMsg "Done!"

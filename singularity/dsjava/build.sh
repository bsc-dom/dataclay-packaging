#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BUILDDIR/../../common/config.sh
if [ -z $EXECUTION_ENVIRONMENT_TAG ]; then echo "ERROR: EXECUTION_ENVIRONMENT_TAG not defined. Aborting"; exit 1; fi

IMAGE_NAME=dsjava
TAG=$EXECUTION_ENVIRONMENT_TAG
source $BUILDDIR/../misc/_build.sh

if [ $EXECUTION_ENVIRONMENT_TAG == $DEFAULT_JDK_TAG ]; then
	rm -f $REPOSITORY/dsjava:latest.sif
	ln -s $REPOSITORY/dsjava:${DEFAULT_JDK_TAG}.sif $REPOSITORY/dsjava:latest.sif
fi 

if [ $DEV == true ]; then 
	rm -f $REPOSITORY/dsjava:${EXECUTION_ENVIRONMENT_TAG/.dev/}.sif
	ln -s $REPOSITORY/dsjava:${EXECUTION_ENVIRONMENT_TAG}.sif $REPOSITORY/dsjava:${EXECUTION_ENVIRONMENT_TAG/.dev/}.sif
fi 
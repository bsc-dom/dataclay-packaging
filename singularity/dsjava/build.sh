#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BUILDDIR/../../common/config.sh
if [ -z $EXECUTION_ENVIRONMENT_TAG ]; then echo "ERROR: EXECUTION_ENVIRONMENT_TAG not defined. Aborting"; exit 1; fi

IMAGE_NAME=dsjava
TAG=$EXECUTION_ENVIRONMENT_TAG
source $BUILDDIR/../misc/_build.sh

if [ $EXECUTION_ENVIRONMENT_TAG == $DEFAULT_JDK_TAG ]; then
	rm -f $REPOSITORY/dsjava.sif
	ln -s dsjava.${DEFAULT_JDK_TAG}.sif $REPOSITORY/dsjava.sif
fi 

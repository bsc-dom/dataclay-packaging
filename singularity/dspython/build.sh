#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BUILDDIR/../../common/config.sh
if [ -z $EXECUTION_ENVIRONMENT_TAG ]; then echo "ERROR: EXECUTION_ENVIRONMENT_TAG not defined. Aborting"; exit 1; fi

# DSPYTHON

IMAGE_NAME=dspython
TAG=$EXECUTION_ENVIRONMENT_TAG
source $BUILDDIR/../misc/_build.sh 

if [ $EXECUTION_ENVIRONMENT_TAG == $DEFAULT_PY_TAG ]; then
	rm -f $REPOSITORY/dspython.sif
	ln -s $REPOSITORY/dspython.${DEFAULT_PY_TAG}.sif $REPOSITORY/dspython.sif
fi 

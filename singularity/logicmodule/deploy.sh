#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BUILDDIR/../../common/config.sh
if [ -z $EXECUTION_ENVIRONMENT_TAG ]; then echo "ERROR: EXECUTION_ENVIRONMENT_TAG not defined. Aborting"; exit 1; fi

LOCAL_REPOSITORY=$(mktemp -d -t singularity-XXXXXXXXXX)

IMAGE_NAME=logicmodule
TAG=$EXECUTION_ENVIRONMENT_TAG
source $BUILDDIR/../misc/_push.sh

######################################## default tags ###########################################
if [ $EXECUTION_ENVIRONMENT_TAG == $DEFAULT_JDK_TAG ]; then
	## Tag default versions 
	yes | singularity delete --arch=amd64 $REPOSITORY/logicmodule:$DEFAULT_TAG || true
	singularity push -U $LOCAL_REPOSITORY/logicmodule:${DEFAULT_JDK_TAG}.sif $REPOSITORY/logicmodule:$DEFAULT_TAG
	
	# Tag latest
	if [ "$DEV" = false ] ; then
		yes | singularity delete --arch=amd64 $REPOSITORY/logicmodule:latest || true
		singularity push -U $LOCAL_REPOSITORY/logicmodule:${DEFAULT_TAG}.sif $REPOSITORY/logicmodule:latest
	fi 
fi
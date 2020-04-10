#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BUILDDIR/../../common/config.sh

LOCAL_REPOSITORY=$(mktemp -d -t singularity-XXXXXXXXXX)

IMAGE_NAME=client
TAG=$CLIENT_TAG
source $BUILDDIR/../misc/_push.sh

# Tag latest
if [ "$DEV" = false ] ; then
	yes | singularity delete --arch=amd64 $REPOSITORY/client:latest || true
	singularity push -U $LOCAL_REPOSITORY/client.${CLIENT_TAG}.sif $REPOSITORY/client:latest
fi 

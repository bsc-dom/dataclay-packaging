#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
REPOSITORY="bscdataclay"
source $BUILDDIR/../../common/config.sh

# BASE IMAGES 
pushd $BUILDDIR
printMsg "Building image named $REPOSITORY/base:$BASE_VERSION_TAG"
docker build -t $REPOSITORY/base:$BASE_VERSION_TAG .
printMsg "$REPOSITORY/base:$BASE_VERSION_TAG IMAGE DONE!" 
popd 

# Tag latest
if [ "$DEV" = false ] ; then
	docker tag $REPOSITORY/base:$DEFAULT_TAG $REPOSITORY/base
fi 
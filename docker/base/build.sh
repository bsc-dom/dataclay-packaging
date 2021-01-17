#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
REPOSITORY="bscdataclay"
source $BUILDDIR/../../common/config.sh


# BASE IMAGES 
pushd $BUILDDIR
printMsg "Building image named $REPOSITORY/base:$BASE_VERSION_TAG"
docker build $DOCKERFILE \
         --build-arg VCS_REF="abc1234" \
         --build-arg BUILD_DATE="0000-00-00" \
         -t $REPOSITORY/base:$BASE_VERSION_TAG .
printMsg "$REPOSITORY/base:$BASE_VERSION_TAG IMAGE DONE!" 
popd 

if [ "$DEV" = false ] ; then
	docker tag $REPOSITORY/base:$DEFAULT_NORMAL_TAG $REPOSITORY/base
	docker tag $REPOSITORY/base:$DEFAULT_TAG $REPOSITORY/base:"${TAG_SUFFIX//-}"
else 
	docker tag $REPOSITORY/base:$DEFAULT_TAG $REPOSITORY/base:develop${TAG_SUFFIX}
fi

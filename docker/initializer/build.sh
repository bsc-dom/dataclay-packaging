#!/bin/bash  -e
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BUILDDIR/../../common/config.sh
pushd $BUILDDIR
build docker $DOCKER_BUILDX_COMMAND build --rm \
         --build-arg VCS_REF="abc1234" \
         --build-arg BUILD_DATE="0000-00-00" \
         --build-arg REGISTRY="${REGISTRY}" \
         --build-arg CLIENT_TAG=$CLIENT_TAG \
			   -t ${REGISTRY}bscdataclay/initializer:$DEFAULT_TAG \
			   $BUILD_PLATFORM $DOCKER_COMMAND .
popd
######################################## default tags ###########################################
if [ "$DEV" = false ] ; then
	docker tag bscdataclay/initializer:$DEFAULT_NORMAL_TAG bscdataclay/initializer
	docker tag bscdataclay/initializer:$DEFAULT_TAG bscdataclay/initializer:"${TAG_SUFFIX//-}"
else
	docker tag bscdataclay/initializer:$DEFAULT_TAG bscdataclay/initializer:develop${TAG_SUFFIX}
fi
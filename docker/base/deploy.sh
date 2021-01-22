#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BUILDDIR/../../common/config.sh
pushd $BUILDDIR
deploy docker buildx build $DOCKERFILE -t bscdataclay/base:$BASE_VERSION_TAG \
    --build-arg VCS_REF=`git rev-parse --short HEAD` \
    --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
    --platform $PLATFORMS $DOCKER_PROGRESS \
    --push .
popd
if [ "$DEV" = false ] ; then
  docker buildx imagetools create --tag bscdataclay/base bscdataclay/base:$DEFAULT_NORMAL_TAG
	[[ ! -z "$TAG_SUFFIX" ]] && docker buildx imagetools create --tag bscdataclay/base:"${TAG_SUFFIX//-}" bscdataclay/base:$DEFAULT_TAG # alpine or slim tags
else 
	docker buildx imagetools create --tag bscdataclay/base:develop${TAG_SUFFIX} bscdataclay/base:$DEFAULT_TAG
fi


RESULT=$?
if [ $RESULT -ne 0 ]; then
   exit 1
fi
printMsg " ===== Done! ===== "




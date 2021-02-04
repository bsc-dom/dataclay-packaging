#!/bin/bash  -e
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BUILDDIR/../../common/config.sh
pushd $BUILDDIR
deploy docker buildx build -t bscdataclay/initializer:$DEFAULT_TAG \
         --build-arg VCS_REF=`git rev-parse --short HEAD` \
         --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
         --build-arg CLIENT_TAG=$CLIENT_TAG \
				 --platform $PLATFORMS $DOCKER_PROGRESS \
				 --push .
popd
if [ "$DEV" = false ] ; then
  docker buildx imagetools create --tag bscdataclay/initializer bscdataclay/initializer:$DEFAULT_NORMAL_TAG
	[[ ! -z "$TAG_SUFFIX" ]] && docker buildx imagetools create --tag bscdataclay/initializer:"${TAG_SUFFIX//-}" bscdataclay/initializer:$DEFAULT_TAG # alpine or slim tags
else
  CUR_DATE_TAG=$(date -u +"%Y%m%d")
	docker buildx imagetools create --tag bscdataclay/initializer:develop${TAG_SUFFIX} bscdataclay/initializer:$DEFAULT_TAG
	docker buildx imagetools create --tag bscdataclay/initializer:dev${CUR_DATE_TAG}${TAG_SUFFIX} bscdataclay/initializer:$DEFAULT_TAG

fi




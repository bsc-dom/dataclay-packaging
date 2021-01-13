#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
REPOSITORY="bscdataclay"
source $BUILDDIR/../../common/config.sh
if [ "$SHARE_BUILDERX" = "false" ]; then
  source $BUILDDIR/../../common/prepare_docker_builder.sh
fi

# BASE IMAGES 
pushd $BUILDDIR
deploy docker buildx build $DOCKERFILE -t $REPOSITORY/base:$BASE_VERSION_TAG \
    --build-arg VCS_REF=`git rev-parse --short HEAD` \
    --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
    --platform $PLATFORMS $DOCKER_PROGRESS \
    --push .
popd

if [ "$DEV" = false ] ; then
  docker buildx imagetools create --tag $REPOSITORY/base $REPOSITORY/base:$DEFAULT_NORMAL_TAG
	[[ ! -z "$TAG_SUFFIX" ]] && docker buildx imagetools create --tag $REPOSITORY/base:"${TAG_SUFFIX//-}" $REPOSITORY/base:$DEFAULT_TAG # alpine or slim tags
else 
	docker buildx imagetools create --tag $REPOSITORY/base:develop${TAG_SUFFIX} $REPOSITORY/base:$DEFAULT_TAG
fi


RESULT=$?
# Remove builder
if [ "$SHARE_BUILDERX" = "false" ]; then
  docker buildx rm $DOCKER_BUILDER
fi
if [ $RESULT -ne 0 ]; then
   exit 1
fi
printMsg " ===== Done! ===== "




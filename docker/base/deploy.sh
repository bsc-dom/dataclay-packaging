#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
REPOSITORY="bscdataclay"
source $BUILDDIR/../../common/config.sh
source $BUILDDIR/../../common/prepare_docker_builder.sh

# BASE IMAGES 
pushd $BUILDDIR
echo "************* Pushing image named $REPOSITORY/base:$BASE_VERSION_TAG *************"
docker buildx build $DOCKERFILE -t $REPOSITORY/base:$BASE_VERSION_TAG \
	--platform $PLATFORMS \
	--cache-to=type=registry,ref=bscdataclay/base:${BASE_VERSION_TAG}-buildxcache,mode=max \
	--cache-from=type=registry,ref=bscdataclay/base:${BASE_VERSION_TAG}-buildxcache \
	--push .
echo "************* $REPOSITORY/base:$BASE_VERSION_TAG IMAGE PUSHED! *************" 
popd

if [ "$DEV" = false ] ; then
  docker buildx imagetools create --tag $REPOSITORY/base $REPOSITORY/base:$DEFAULT_NORMAL_TAG
	[[ -z "$TAG_SUFFIX" ]] && docker buildx imagetools create --tag $REPOSITORY/base:"${TAG_SUFFIX//-}" $REPOSITORY/base:$DEFAULT_TAG # alpine or slim tags
else 
	docker buildx imagetools create --tag $REPOSITORY/base:develop${TAG_SUFFIX} $REPOSITORY/base:$DEFAULT_TAG
fi

# Remove builder
docker buildx rm $DOCKER_BUILDER
printMsg " ===== Done! ====="




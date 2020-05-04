#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
REPOSITORY="bscdataclay"
source $BUILDDIR/../../common/config.sh
source $BUILDDIR/../../common/prepare_docker_builder.sh

# BASE IMAGES 
pushd $BUILDDIR
echo "************* Pushing image named $REPOSITORY/base:$BASE_VERSION_TAG *************"
docker buildx build -t $REPOSITORY/base:$BASE_VERSION_TAG \
	--platform $PLATFORMS \
	--cache-to=type=registry,ref=bscdataclay/base:buildxcache,mode=max \
	--cache-from=type=registry,ref=bscdataclay/base:buildxcache \
	--push .
echo "************* $REPOSITORY/base:$BASE_VERSION_TAG IMAGE PUSHED! *************" 
popd

##### TAG LATEST #####
if [ "$DEV" = false ] ; then
	docker buildx imagetools create --tag $REPOSITORY/base $REPOSITORY/base:$DEFAULT_TAG
fi

# Remove builder
docker buildx rm $DOCKER_BUILDER
printMsg " ===== Done! ====="




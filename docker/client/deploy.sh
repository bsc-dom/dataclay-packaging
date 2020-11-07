#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
REPOSITORY="bscdataclay"
source $BUILDDIR/../../common/config.sh
if [ "$SHARE_BUILDERX" = "false" ]; then
  source $BUILDDIR/../../common/prepare_docker_builder.sh
fi

# CLIENT 
pushd $BUILDDIR
# client will not have execution environemnt in version, like pypi
echo "************* Pushing image named $REPOSITORY/client:$CLIENT_TAG (retry $n) *************"
deploy docker buildx build $DOCKERFILE -t $REPOSITORY/client:$CLIENT_TAG \
         --build-arg VCS_REF=`git rev-parse --short HEAD` \
         --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT00:00:00Z"` \
         --build-arg VERSION=$CLIENT_TAG \
				 --build-arg DATACLAY_DSPYTHON_DOCKER_TAG=$DEFAULT_PY_CLIENT_TAG \
				 --build-arg DATACLAY_LOGICMODULE_DOCKER_TAG=$DEFAULT_JDK_CLIENT_TAG \
				 --build-arg DATACLAY_PYVER=$CLIENT_PYTHON \
			   --build-arg JDK=$CLIENT_JAVA \
			   --cache-to=type=registry,ref=bscdataclay/client:${CLIENT_TAG}-buildxcache,mode=max \
	       --cache-from=type=registry,ref=bscdataclay/client:${CLIENT_TAG}-buildxcache \
				 --platform $PLATFORMS \
				 --push .

echo "************* $REPOSITORY/client:$CLIENT_TAG IMAGE PUSHED! (in $n retries) *************"
popd 

if [ "$DEV" = false ] ; then
  docker buildx imagetools create --tag $REPOSITORY/client $REPOSITORY/client:$DEFAULT_NORMAL_TAG
	[[ ! -z "$TAG_SUFFIX" ]] && docker buildx imagetools create --tag $REPOSITORY/client:"${TAG_SUFFIX//-}" $REPOSITORY/client:$DEFAULT_TAG # alpine or slim tags
else 
	docker buildx imagetools create --tag $REPOSITORY/client:develop${TAG_SUFFIX} $REPOSITORY/client:$DEFAULT_TAG
fi

# Remove builder
if [ "$SHARE_BUILDERX" = "false" ]; then
  docker buildx rm $DOCKER_BUILDER
fi
printMsg " ===== Done! (in $n retries) ====="




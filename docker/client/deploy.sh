#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
REPOSITORY="bscdataclay"
source $BUILDDIR/../../common/config.sh
source $BUILDDIR/../../common/prepare_docker_builder.sh

# CLIENT 
pushd $BUILDDIR
# client will not have execution environemnt in version, like pypi
echo "************* Building image named $REPOSITORY/client:$CLIENT_TAG *************"
docker buildx build -t $REPOSITORY/client:$CLIENT_TAG \
	--build-arg DATACLAY_DSPYTHON_DOCKER_TAG=$DEFAULT_PY_TAG \
	--build-arg DATACLAY_LOGICMODULE_DOCKER_TAG=$DEFAULT_JDK_TAG \
	--build-arg DATACLAY_PYVER=$DEFAULT_PYTHON \
	--platform $PLATFORMS \
	--cache-to=type=local,dest=${DOCKERX_CACHE},mode=max $EXTRA_ARGS \
	--push .
echo "************* $REPOSITORY/client:$CLIENT_TAG DONE! *************"
popd 

##### TAG LATEST #####
if [ "$DEV" = false ] ; then
	docker buildx imagetools create --tag $REPOSITORY/client $REPOSITORY/client:$DEFAULT_TAG
fi

# Remove builder
docker buildx rm $DOCKER_BUILDER
printMsg " ===== Done! ====="




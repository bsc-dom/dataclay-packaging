#!/bin/bash -e
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BUILDDIR/../../common/config.sh
pushd $BUILDDIR
build docker $DOCKER_BUILDX_COMMAND build --rm $DOCKERFILE \
         --build-arg VCS_REF="abc1234" \
         --build-arg BUILD_DATE="0000-00-00" \
         --build-arg REGISTRY="${REGISTRY}" \
         --build-arg VERSION=$CLIENT_TAG \
				 --build-arg DATACLAY_DSPYTHON_DOCKER_TAG=$DEFAULT_PY_CLIENT_TAG \
				 --build-arg DATACLAY_LOGICMODULE_DOCKER_TAG=$DEFAULT_JDK_CLIENT_TAG \
				 --build-arg DATACLAY_PYVER=$CLIENT_PYTHON \
			   --build-arg JDK=$CLIENT_JAVA \
				 -t ${REGISTRY}bscdataclay/client:$CLIENT_TAG \
				 $BUILD_PLATFORM $DOCKER_COMMAND .
popd

if [ "$DEV" = false ] ; then
	docker tag bscdataclay/client:$DEFAULT_NORMAL_TAG bscdataclay/client
	docker tag bscdataclay/client:$CLIENT_TAG bscdataclay/client:"${TAG_SUFFIX//-}"
else 
	docker tag bscdataclay/client:$CLIENT_TAG bscdataclay/client:develop${TAG_SUFFIX}
fi

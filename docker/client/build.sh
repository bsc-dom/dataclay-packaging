#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
REPOSITORY="bscdataclay"
source $BUILDDIR/../../common/config.sh

# CLIENT 
pushd $BUILDDIR
# client will not have execution environemnt in version, like pypi
printMsg "Building image named $REPOSITORY/client:$CLIENT_TAG"
docker build $DOCKERFILE \
				 --build-arg DATACLAY_DSPYTHON_DOCKER_TAG=$DEFAULT_PY_CLIENT_TAG \
				 --build-arg DATACLAY_LOGICMODULE_DOCKER_TAG=$DEFAULT_JDK_CLIENT_TAG \
				 --build-arg DATACLAY_PYVER=$CLIENT_PYTHON \
			     --build-arg JDK=$CLIENT_JAVA \
				 -t $REPOSITORY/client:$CLIENT_TAG .
printMsg "$REPOSITORY/client:$CLIENT_TAG DONE!"
popd 
	
if [ "$DEV" = false ] ; then
	docker tag $REPOSITORY/client:$DEFAULT_TAG $REPOSITORY/client 
else 
	docker tag $REPOSITORY/client:$DEFAULT_TAG $REPOSITORY/client:develop${TAG_SUFFIX}
fi

#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
REPOSITORY="bscdataclay"
source $BUILDDIR/../../common/config.sh

# CLIENT 
pushd $BUILDDIR
# client will not have execution environemnt in version, like pypi
printMsg "Building image named $REPOSITORY/client:$CLIENT_TAG"
docker build --build-arg DATACLAY_DSPYTHON_DOCKER_TAG=$DEFAULT_PY_TAG \
			 --build-arg DATACLAY_LOGICMODULE_DOCKER_TAG=$DEFAULT_JDK_TAG \
			 --build-arg DATACLAY_PYVER=$DEFAULT_PYTHON \
			 -t $REPOSITORY/client:$CLIENT_TAG .
printMsg "$REPOSITORY/client:$CLIENT_TAG DONE!"
popd 

# Tag latest
docker tag $REPOSITORY/client:$DEFAULT_TAG $REPOSITORY/client 

#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

REPOSITORY="bscdataclay"
source $BUILDDIR/../../../common/config.sh
if [ -z $EXECUTION_ENVIRONMENT_TAG ]; then echo "ERROR: EXECUTION_ENVIRONMENT_TAG not defined. Aborting"; exit 1; fi
source $BUILDDIR/../../../common/prepare_docker_builder.sh
	
# DSPYTHON
pushd $BUILDDIR
# Get python version without subversion to install it in some packages
PYTHON_PIP_VERSION=$(echo $PYTHON_VERSION | awk -F '.' '{print $1}')
echo "************* Building image named $REPOSITORY/dspython:${EXECUTION_ENVIRONMENT_TAG}-requirements python version $PYTHON_VERSION and pip version $PYTHON_PIP_VERSION *************"
docker buildx build $DOCKERFILE \
			-t $REPOSITORY/dspython:${EXECUTION_ENVIRONMENT_TAG}-requirements \
			--build-arg DATACLAY_PYVER=$PYTHON_VERSION \
			--build-arg PYTHON_PIP_VERSION=$PYTHON_PIP_VERSION \
			--platform $PLATFORMS \
			--cache-to=type=registry,ref=bscdataclay/dspython:buildxcache${EXECUTION_ENVIRONMENT_TAG}-requirements,mode=max \
			--cache-from=type=registry,ref=bscdataclay/dspython:buildxcache${EXECUTION_ENVIRONMENT_TAG}-requirements \
			--push .
echo "************* $REPOSITORY/dspython:${EXECUTION_ENVIRONMENT_TAG}-requirements DONE! *************"
popd 
	
# Remove builder
docker buildx rm $DOCKER_BUILDER
printMsg " ===== Done! ====="




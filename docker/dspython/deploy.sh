#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
REPOSITORY="bscdataclay"
source $BUILDDIR/../../common/config.sh
if [ -z $EXECUTION_ENVIRONMENT_TAG ]; then echo "ERROR: EXECUTION_ENVIRONMENT_TAG not defined. Aborting"; exit 1; fi
source $BUILDDIR/../../common/prepare_docker_builder.sh

# DSPYTHON
pushd $BUILDDIR
# Get python version without subversion to install it in some packages
PYTHON_PIP_VERSION=$(echo $PYTHON_VERSION | awk -F '.' '{print $1}')
echo "************* Building image named $REPOSITORY/dspython:$EXECUTION_ENVIRONMENT_TAG python version $PYTHON_VERSION and pip version $PYTHON_PIP_VERSION *************"
docker buildx build $DOCKERFILE -t $REPOSITORY/dspython:$EXECUTION_ENVIRONMENT_TAG \
		--build-arg BASE_VERSION=$BASE_VERSION_TAG \
		--build-arg REQUIREMENTS_TAG=${EXECUTION_ENVIRONMENT_TAG}-requirements \
		--build-arg DATACLAY_PYVER=$PYTHON_VERSION \
		--build-arg PYTHON_PIP_VERSION=$PYTHON_PIP_VERSION \
		--platform $PLATFORMS \
		--cache-to=type=registry,ref=bscdataclay/dspython:${EXECUTION_ENVIRONMENT_TAG}-buildxcache,mode=max \
		--cache-from=type=registry,ref=bscdataclay/dspython:${EXECUTION_ENVIRONMENT_TAG}-buildxcache \
		--push .
echo "************* $REPOSITORY/dspython:$EXECUTION_ENVIRONMENT_TAG DONE! *************"
popd 


######################################## tags ###########################################
if [ $EXECUTION_ENVIRONMENT_TAG == $DEFAULT_PY_TAG ]; then
	## Tag default versions 
	docker buildx imagetools create --tag $REPOSITORY/dspython:$DEFAULT_TAG $REPOSITORY/dspython:$DEFAULT_PY_TAG	
	##### TAG LATEST #####
	if [ "$DEV" = false ] ; then
		docker buildx imagetools create --tag $REPOSITORY/dspython $REPOSITORY/dspython:$DEFAULT_TAG
	else 
		docker buildx imagetools create --tag $REPOSITORY/dspython:develop${TAG_SUFFIX} $REPOSITORY/dspython:$DEFAULT_TAG
	fi
fi
if [ "$DEV" = true ] ; then 
	DATACLAY_PYTHON_VERSION="${PYTHON_VERSION//./}"
	docker buildx imagetools create --tag $REPOSITORY/dspython:develop.py${DATACLAY_PYTHON_VERSION}${TAG_SUFFIX} $REPOSITORY/dspython:$EXECUTION_ENVIRONMENT_TAG
fi 
#################################################################################################

# Remove builder
docker buildx rm $DOCKER_BUILDER
printMsg " ===== Done! ====="




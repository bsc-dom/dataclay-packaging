#!/bin/bash  -e
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BUILDDIR/../../common/config.sh
if [ -z $EXECUTION_ENVIRONMENT_TAG ]; then echo "ERROR: EXECUTION_ENVIRONMENT_TAG not defined. Aborting"; exit 1; fi
pushd $BUILDDIR
build docker $DOCKER_BUILDX_COMMAND build --rm $DOCKERFILE \
       --build-arg VCS_REF="abc1234" \
       --build-arg BUILD_DATE="0000-00-00" \
       --build-arg VERSION=$EXECUTION_ENVIRONMENT_TAG \
			 --build-arg BASE_VERSION=$BASE_VERSION_TAG \
			 --build-arg REQUIREMENTS_TAG=${EXECUTION_ENVIRONMENT_TAG}-requirements \
			 --build-arg DATACLAY_PYVER=$PYTHON_VERSION \
			 --build-arg PYTHON_PIP_VERSION=$PYTHON_PIP_VERSION \
			 -t ${REGISTRY}bscdataclay/dspython:$EXECUTION_ENVIRONMENT_TAG \
			 $BUILD_PLATFORM $DOCKER_COMMAND .
popd
######################################## default tags ############################c###############
CUR_DATE_TAG=$(date -u +"%Y%m%d")
if [ $EXECUTION_ENVIRONMENT_TAG == $DEFAULT_PY_TAG ]; then
	## Tag default versions 
	docker tag bscdataclay/dspython:$DEFAULT_PY_TAG bscdataclay/dspython:$DEFAULT_TAG
		
	# Tag latest
	if [ "$DEV" = false ] ; then
		docker tag bscdataclay/dspython:$DEFAULT_NORMAL_TAG bscdataclay/dspython
	  docker tag bscdataclay/dspython:$DEFAULT_TAG bscdataclay/dspython:"${TAG_SUFFIX//-}"
	else 
		docker tag bscdataclay/dspython:$DEFAULT_TAG bscdataclay/dspython:develop${TAG_SUFFIX} #develop-slim, develop-alpine
		if [ "$ADD_DATE_TAG" = true ] ; then
		  docker tag bscdataclay/dspython:$DEFAULT_TAG bscdataclay/dspython:dev${CUR_DATE_TAG}${TAG_SUFFIX} #develop-slim, develop-alpine
    fi
	fi
fi
if [ "$DEV" = true ] ; then 
	DATACLAY_PYTHON_VERSION="${PYTHON_VERSION//./}"
	docker tag bscdataclay/dspython:$EXECUTION_ENVIRONMENT_TAG bscdataclay/dspython:develop.py${DATACLAY_PYTHON_VERSION}${TAG_SUFFIX} #develop.py36-slim
	if [ "$ADD_DATE_TAG" = true ] ; then
	  docker tag bscdataclay/dspython:$EXECUTION_ENVIRONMENT_TAG bscdataclay/dspython:dev${CUR_DATE_TAG}.py${DATACLAY_PYTHON_VERSION}${TAG_SUFFIX} #develop.py36-slim
  fi
fi
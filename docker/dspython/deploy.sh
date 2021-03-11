#!/bin/bash  -e
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BUILDDIR/../../common/config.sh
if [ -z $EXECUTION_ENVIRONMENT_TAG ]; then echo "ERROR: EXECUTION_ENVIRONMENT_TAG not defined. Aborting"; exit 1; fi

pushd $BUILDDIR
# Get python version without subversion to install it in some packages
PYTHON_PIP_VERSION=$(echo $PYTHON_VERSION | awk -F '.' '{print $1}')
deploy docker buildx build $DOCKERFILE -t bscdataclay/dspython:$EXECUTION_ENVIRONMENT_TAG \
    --build-arg VCS_REF=`git rev-parse --short HEAD` \
    --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
    --build-arg VERSION=$EXECUTION_ENVIRONMENT_TAG \
		--build-arg BASE_VERSION=$BASE_VERSION_TAG \
		--build-arg REQUIREMENTS_TAG=${REQUIREMENTS_TAG} \
		--build-arg DATACLAY_PYVER=$PYTHON_VERSION \
		--build-arg PYTHON_PIP_VERSION=$PYTHON_PIP_VERSION \
		--platform $PLATFORMS $DOCKER_PROGRESS \
		--push .

popd

######################################## tags ###########################################
CUR_DATE_TAG=$(date -u +"%Y%m%d")
if [ $EXECUTION_ENVIRONMENT_TAG == $DEFAULT_PY_TAG ]; then
	## Tag default versions 
	docker buildx imagetools create --tag bscdataclay/dspython:$DEFAULT_TAG bscdataclay/dspython:$DEFAULT_PY_TAG	
	##### TAG LATEST #####
	if [ "$DEV" = false ] ; then
		docker buildx imagetools create --tag bscdataclay/dspython bscdataclay/dspython:$DEFAULT_NORMAL_TAG
		[[ ! -z "$TAG_SUFFIX" ]] && docker buildx imagetools create --tag bscdataclay/dspython:"${TAG_SUFFIX//-}" bscdataclay/dspython:$DEFAULT_TAG # alpine or slim tags
	else 
		docker buildx imagetools create --tag bscdataclay/dspython:develop${TAG_SUFFIX} bscdataclay/dspython:$DEFAULT_TAG
		if [ "$ADD_DATE_TAG" = true ] ; then
		  docker buildx imagetools create --tag bscdataclay/dspython:dev${CUR_DATE_TAG}${TAG_SUFFIX} bscdataclay/dspython:$DEFAULT_TAG
    fi
	fi
fi
if [ "$DEV" = true ] ; then 
	DATACLAY_PYTHON_VERSION="${PYTHON_VERSION//./}"
	docker buildx imagetools create --tag bscdataclay/dspython:develop.py${DATACLAY_PYTHON_VERSION}${TAG_SUFFIX} bscdataclay/dspython:$EXECUTION_ENVIRONMENT_TAG
	if [ "$ADD_DATE_TAG" = true ] ; then
	  docker buildx imagetools create --tag bscdataclay/dspython:dev${CUR_DATE_TAG}.py${DATACLAY_PYTHON_VERSION}${TAG_SUFFIX} bscdataclay/dspython:$EXECUTION_ENVIRONMENT_TAG
  fi
fi
#################################################################################################




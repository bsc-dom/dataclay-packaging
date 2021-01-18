#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
REPOSITORY="bscdataclay"
source $BUILDDIR/../../common/config.sh
if [ -z $EXECUTION_ENVIRONMENT_TAG ]; then echo "ERROR: EXECUTION_ENVIRONMENT_TAG not defined. Aborting"; exit 1; fi
if [ "$SHARE_BUILDER" = "false" ]; then
  source $BUILDDIR/../../common/prepare_docker_builder.sh
fi

# DSPYTHON
pushd $BUILDDIR
# Get python version without subversion to install it in some packages
PYTHON_PIP_VERSION=$(echo $PYTHON_VERSION | awk -F '.' '{print $1}')

deploy docker buildx build $DOCKERFILE -t $REPOSITORY/dspython:$EXECUTION_ENVIRONMENT_TAG \
    --build-arg VCS_REF=`git rev-parse --short HEAD` \
    --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
    --build-arg VERSION=$EXECUTION_ENVIRONMENT_TAG \
		--build-arg BASE_VERSION=$BASE_VERSION_TAG \
		--build-arg REQUIREMENTS_TAG=${EXECUTION_ENVIRONMENT_TAG}-requirements \
		--build-arg DATACLAY_PYVER=$PYTHON_VERSION \
		--build-arg PYTHON_PIP_VERSION=$PYTHON_PIP_VERSION \
		--platform $PLATFORMS $DOCKER_PROGRESS \
		--push .

popd


######################################## tags ###########################################
if [ $EXECUTION_ENVIRONMENT_TAG == $DEFAULT_PY_TAG ]; then
	## Tag default versions 
	docker buildx imagetools create --tag $REPOSITORY/dspython:$DEFAULT_TAG $REPOSITORY/dspython:$DEFAULT_PY_TAG	
	##### TAG LATEST #####
	if [ "$DEV" = false ] ; then
		docker buildx imagetools create --tag $REPOSITORY/dspython $REPOSITORY/dspython:$DEFAULT_NORMAL_TAG
		[[ ! -z "$TAG_SUFFIX" ]] && docker buildx imagetools create --tag $REPOSITORY/dspython:"${TAG_SUFFIX//-}" $REPOSITORY/dspython:$DEFAULT_TAG # alpine or slim tags
	else 
		docker buildx imagetools create --tag $REPOSITORY/dspython:develop${TAG_SUFFIX} $REPOSITORY/dspython:$DEFAULT_TAG
	fi
fi
if [ "$DEV" = true ] ; then 
	DATACLAY_PYTHON_VERSION="${PYTHON_VERSION//./}"
	docker buildx imagetools create --tag $REPOSITORY/dspython:develop.py${DATACLAY_PYTHON_VERSION}${TAG_SUFFIX} $REPOSITORY/dspython:$EXECUTION_ENVIRONMENT_TAG
fi 
#################################################################################################

RESULT=$?
# Remove builder
if [ "$SHARE_BUILDER" = "false" ]; then
  docker buildx rm dataclay-builderx
fi
if [ $RESULT -ne 0 ]; then
   exit 1
fi
printMsg " ===== Done! ===== "




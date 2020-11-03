#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
REPOSITORY="bscdataclay"
source $BUILDDIR/../../common/config.sh
if [ -z $EXECUTION_ENVIRONMENT_TAG ]; then echo "ERROR: EXECUTION_ENVIRONMENT_TAG not defined. Aborting"; exit 1; fi

# DSPYTHON
pushd $BUILDDIR
printMsg "Building image named $REPOSITORY/dspython:$EXECUTION_ENVIRONMENT_TAG python version $PYTHON_VERSION and pip version $PYTHON_PIP_VERSION"
docker build --rm $DOCKERFILE \
       --build-arg VCS_REF=`git rev-parse --short HEAD` \
       --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT00:00:00Z"` \
       --build-arg VERSION=$EXECUTION_ENVIRONMENT_TAG \
			 --build-arg BASE_VERSION=$BASE_VERSION_TAG \
			 --build-arg REQUIREMENTS_TAG=${EXECUTION_ENVIRONMENT_TAG}-requirements \
			 --build-arg DATACLAY_PYVER=$PYTHON_VERSION \
			 --build-arg PYTHON_PIP_VERSION=$PYTHON_PIP_VERSION \
			 -t $REPOSITORY/dspython:$EXECUTION_ENVIRONMENT_TAG .
printMsg "$REPOSITORY/dspython:$EXECUTION_ENVIRONMENT_TAG DONE!"
popd 
	
######################################## default tags ############################c###############
if [ $EXECUTION_ENVIRONMENT_TAG == $DEFAULT_PY_TAG ]; then
	## Tag default versions 
	docker tag $REPOSITORY/dspython:$DEFAULT_PY_TAG $REPOSITORY/dspython:$DEFAULT_TAG
		
	# Tag latest
	if [ "$DEV" = false ] ; then
		docker tag $REPOSITORY/dspython:$DEFAULT_NORMAL_TAG $REPOSITORY/dspython
	  docker tag $REPOSITORY/dspython:$DEFAULT_TAG $REPOSITORY/dspython:"${TAG_SUFFIX//-}"
	else 
		docker tag $REPOSITORY/dspython:$DEFAULT_TAG $REPOSITORY/dspython:develop${TAG_SUFFIX} #develop-slim, develop-alpine
	fi
fi
if [ "$DEV" = true ] ; then 
	DATACLAY_PYTHON_VERSION="${PYTHON_VERSION//./}"
	docker tag $REPOSITORY/dspython:$EXECUTION_ENVIRONMENT_TAG $REPOSITORY/dspython:develop.py${DATACLAY_PYTHON_VERSION}${TAG_SUFFIX} #develop.py36-slim
fi
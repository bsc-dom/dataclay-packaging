#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
REPOSITORY="bscdataclay"
source $BUILDDIR/../../common/config.sh
if [ -z $EXECUTION_ENVIRONMENT_TAG ]; then echo "ERROR: EXECUTION_ENVIRONMENT_TAG not defined. Aborting"; exit 1; fi

# DSPYTHON
pushd $BUILDDIR
# Get python version without subversion to install it in some packages
PYTHON_PIP_VERSION=$PYTHON_VERSION
PYTHON_PIP_VERSION=$(echo $PYTHON_VERSION | awk -F '.' '{print $1}')
printMsg "Building image named $REPOSITORY/dspython:$EXECUTION_ENVIRONMENT_TAG python version $PYTHON_VERSION and pip version $PYTHON_PIP_VERSION"
docker build --build-arg BASE_VERSION=$BASE_VERSION_TAG \
				 --build-arg DATACLAY_PYVER=$PYTHON_VERSION \
				 --build-arg PYTHON_PIP_VERSION=$PYTHON_PIP_VERSION -t $REPOSITORY/dspython:$EXECUTION_ENVIRONMENT_TAG .
printMsg "$REPOSITORY/dspython:$EXECUTION_ENVIRONMENT_TAG DONE!"
popd 

######################################## default tags ###########################################
if [ $EXECUTION_ENVIRONMENT_TAG == $DEFAULT_PY_TAG ]; then
	## Tag default versions 
	docker tag $REPOSITORY/dspython:$DEFAULT_PY_TAG $REPOSITORY/dspython:$DEFAULT_TAG
	
	# Tag latest
	docker tag $REPOSITORY/dspython:$DEFAULT_TAG $REPOSITORY/dspython 
fi 

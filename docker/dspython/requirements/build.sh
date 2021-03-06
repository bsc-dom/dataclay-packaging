#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BUILDDIR/../../../common/config.sh
if [ -z $EXECUTION_ENVIRONMENT_TAG ]; then echo "ERROR: EXECUTION_ENVIRONMENT_TAG not defined. Aborting"; exit 1; fi
	

# Get python version without subversion to install it in some packages
PYTHON_PIP_VERSION=$(echo $PYTHON_VERSION | awk -F '.' '{print $1}')
build docker build $DOCKERFILE \
					 --build-arg DATACLAY_PYVER=$PYTHON_VERSION \
					 --build-arg PYTHON_PIP_VERSION=$PYTHON_PIP_VERSION -t bscdataclay/dspython:${EXECUTION_ENVIRONMENT_TAG}-requirements .

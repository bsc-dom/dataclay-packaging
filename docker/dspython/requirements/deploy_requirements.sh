#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

source $BUILDDIR/../../../common/PLATFORMS.txt
source $SCRIPTDIR/../common/prepare_docker_builder.sh
for PYTHON_VERSION in ${SUPPORTED_PYTHON_VERSIONS[@]}; do
	$BUILDDIR/deploy.sh "$@" --ee py${PYTHON_VERSION} --share-builder
	$BUILDDIR/deploy.sh "$@" --ee py${PYTHON_VERSION} --slim --share-builder
	$BUILDDIR/deploy.sh "$@" --ee py${PYTHON_VERSION} --alpine --share-builder
done




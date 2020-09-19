#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BUILDDIR/../../../common/PLATFORMS.txt
for PYTHON_VERSION in ${SUPPORTED_PYTHON_VERSIONS[@]}; do
	$BUILDDIR/build.sh "$@" --ee py${PYTHON_VERSION}
done
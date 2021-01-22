#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BUILDDIR/../../common/config.sh
pushd $BUILDDIR
build docker build $DOCKERFILE \
         --build-arg VCS_REF="abc1234" \
         --build-arg BUILD_DATE="0000-00-00" \
         -t bscdataclay/base:$BASE_VERSION_TAG .
popd
if [ "$DEV" = false ] ; then
	docker tag bscdataclay/base:$DEFAULT_NORMAL_TAG bscdataclay/base
	docker tag bscdataclay/base:$DEFAULT_TAG bscdataclay/base:"${TAG_SUFFIX//-}"
else 
	docker tag bscdataclay/base:$DEFAULT_TAG bscdataclay/base:develop${TAG_SUFFIX}
fi

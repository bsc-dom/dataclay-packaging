#!/bin/bash  -e
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BUILDDIR/../../common/config.sh
pushd $BUILDDIR
deploy docker buildx build $DOCKERFILE -t bscdataclay/client:$CLIENT_TAG \
         --build-arg VCS_REF=`git rev-parse --short HEAD` \
         --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
         --build-arg VERSION=$CLIENT_TAG \
				 --build-arg DATACLAY_DSPYTHON_DOCKER_TAG=$DEFAULT_PY_CLIENT_TAG \
				 --build-arg DATACLAY_LOGICMODULE_DOCKER_TAG=$DEFAULT_JDK_CLIENT_TAG \
				 --build-arg DATACLAY_PYVER=$CLIENT_PYTHON \
			   --build-arg JDK=$CLIENT_JAVA \
				 --platform $PLATFORMS $DOCKER_PROGRESS \
				 --push .
popd
if [ "$DEV" = false ] ; then
  docker buildx imagetools create --tag bscdataclay/client bscdataclay/client:$DEFAULT_NORMAL_TAG
	[[ ! -z "$TAG_SUFFIX" ]] && docker buildx imagetools create --tag bscdataclay/client:"${TAG_SUFFIX//-}" bscdataclay/client:$DEFAULT_TAG # alpine or slim tags
else
	docker buildx imagetools create --tag bscdataclay/client:develop${TAG_SUFFIX} bscdataclay/client:$DEFAULT_TAG
	if [ "$ADD_DATE_TAG" = true ] ; then
	  CUR_DATE_TAG=$(date -u +"%Y%m%d")
	  docker buildx imagetools create --tag bscdataclay/client:dev${CUR_DATE_TAG}${TAG_SUFFIX} bscdataclay/client:$DEFAULT_TAG
  fi
fi




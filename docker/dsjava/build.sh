#!/bin/bash  -e
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BUILDDIR/../../common/config.sh
if [ -z $EXECUTION_ENVIRONMENT_TAG ]; then echo "ERROR: EXECUTION_ENVIRONMENT_TAG not defined. Aborting"; exit 1; fi
pushd $BUILDDIR
build docker $DOCKER_BUILDX_COMMAND build --rm $DOCKERFILE \
         --build-arg VCS_REF="abc1234" \
         --build-arg BUILD_DATE="0000-00-00" \
         --build-arg REGISTRY="${REGISTRY}" \
         --build-arg VERSION=$EXECUTION_ENVIRONMENT_TAG \
			   --build-arg LOGICMODULE_VERSION=$EXECUTION_ENVIRONMENT_TAG \
			   -t ${REGISTRY}bscdataclay/dsjava:$EXECUTION_ENVIRONMENT_TAG \
			   $BUILD_PLATFORM $DOCKER_COMMAND .
popd
######################################## default tags ###########################################
CUR_DATE_TAG=$(date -u +"%Y%m%d")
if [ $EXECUTION_ENVIRONMENT_TAG == $DEFAULT_JDK_TAG ]; then
	## Tag default versions 
	docker tag bscdataclay/dsjava:$DEFAULT_JDK_TAG bscdataclay/dsjava:$DEFAULT_TAG
		
	if [ "$DEV" = false ] ; then
	  docker tag bscdataclay/dsjava:$DEFAULT_NORMAL_TAG bscdataclay/dsjava
	  docker tag bscdataclay/dsjava:$DEFAULT_TAG bscdataclay/dsjava:"${TAG_SUFFIX//-}"
	else 
		docker tag bscdataclay/dsjava:$DEFAULT_TAG bscdataclay/dsjava:develop${TAG_SUFFIX} #develop-slim, develop-alpine
		if [ "$ADD_DATE_TAG" = true ] ; then
		  docker tag bscdataclay/dsjava:$DEFAULT_TAG bscdataclay/dsjava:dev${CUR_DATE_TAG}${TAG_SUFFIX} #develop-slim, develop-alpine
    fi
	fi
fi
if [ "$DEV" = true ] ; then 
	docker tag bscdataclay/dsjava:$EXECUTION_ENVIRONMENT_TAG bscdataclay/dsjava:develop.jdk${JAVA_VERSION}${TAG_SUFFIX} #develop.jdk11-slim
	if [ "$ADD_DATE_TAG" = true ] ; then
	  docker tag bscdataclay/dsjava:$EXECUTION_ENVIRONMENT_TAG bscdataclay/dsjava:dev${CUR_DATE_TAG}.jdk${JAVA_VERSION}${TAG_SUFFIX} #develop.jdk11-slim
  fi
fi
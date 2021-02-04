#!/bin/bash  -e
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BUILDDIR/../../common/config.sh
if [ -z $EXECUTION_ENVIRONMENT_TAG ]; then echo "ERROR: EXECUTION_ENVIRONMENT_TAG not defined. Aborting"; exit 1; fi
pushd $BUILDDIR
deploy docker buildx build $DOCKERFILE -t bscdataclay/dsjava:$EXECUTION_ENVIRONMENT_TAG \
         --build-arg VCS_REF=`git rev-parse --short HEAD` \
         --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
         --build-arg VERSION=$EXECUTION_ENVIRONMENT_TAG \
		     --build-arg LOGICMODULE_VERSION=$EXECUTION_ENVIRONMENT_TAG \
		     --platform $PLATFORMS $DOCKER_PROGRESS \
		     --push .
popd
######################################## tags ###########################################
CUR_DATE_TAG=$(date -u +"%Y%m%d")
if [ $EXECUTION_ENVIRONMENT_TAG == $DEFAULT_JDK_TAG ]; then
	## Tag default versions 
	docker buildx imagetools create --tag bscdataclay/dsjava:$DEFAULT_TAG bscdataclay/dsjava:$DEFAULT_JDK_TAG
	
	##### TAG LATEST #####
	if [ "$DEV" = false ] ; then
		docker buildx imagetools create --tag bscdataclay/dsjava bscdataclay/dsjava:$DEFAULT_NORMAL_TAG
		[[ ! -z "$TAG_SUFFIX" ]] && docker buildx imagetools create --tag bscdataclay/dsjava:"${TAG_SUFFIX//-}" bscdataclay/dsjava:$DEFAULT_TAG # alpine or slim tags
	else 
		docker buildx imagetools create --tag bscdataclay/dsjava:develop${TAG_SUFFIX} bscdataclay/dsjava:$DEFAULT_TAG
		docker buildx imagetools create --tag bscdataclay/dsjava:dev${CUR_DATE_TAG}${TAG_SUFFIX} bscdataclay/dsjava:$DEFAULT_TAG

	fi
fi
if [ "$DEV" = true ] ; then 
	docker buildx imagetools create --tag bscdataclay/dsjava:develop.jdk${JAVA_VERSION}${TAG_SUFFIX} bscdataclay/dsjava:$EXECUTION_ENVIRONMENT_TAG
	docker buildx imagetools create --tag bscdataclay/dsjava:dev${CUR_DATE_TAG}.jdk${JAVA_VERSION}${TAG_SUFFIX} bscdataclay/dsjava:$EXECUTION_ENVIRONMENT_TAG

fi
#################################################################################################




#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
REPOSITORY="bscdataclay"
source $BUILDDIR/../../common/config.sh
if [ -z $EXECUTION_ENVIRONMENT_TAG ]; then echo "ERROR: EXECUTION_ENVIRONMENT_TAG not defined. Aborting"; exit 1; fi
if [ "$SHARE_BUILDERX" = "false" ]; then
  source $BUILDDIR/../../common/prepare_docker_builder.sh
fi

# DSJAVA
pushd $BUILDDIR

echo "************* Pushing image named $REPOSITORY/dsjava:$EXECUTION_ENVIRONMENT_TAG (retry $n) *************"
deploy docker buildx build $DOCKERFILE -t $REPOSITORY/dsjava:$EXECUTION_ENVIRONMENT_TAG \
         --build-arg VCS_REF=`git rev-parse --short HEAD` \
         --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT00:00:00Z"` \
         --build-arg VERSION=$EXECUTION_ENVIRONMENT_TAG \
		     --build-arg LOGICMODULE_VERSION=$EXECUTION_ENVIRONMENT_TAG \
		     --cache-to=type=registry,ref=bscdataclay/dsjava:${EXECUTION_ENVIRONMENT_TAG}-buildxcache,mode=max \
	       --cache-from=type=registry,ref=bscdataclay/dsjava:${EXECUTION_ENVIRONMENT_TAG}-buildxcache \
		     --platform $PLATFORMS \
		     --push .

echo "************* $REPOSITORY/dsjava:$EXECUTION_ENVIRONMENT_TAG IMAGE PUSHED! (in $n retries) *************"
popd 

######################################## tags ###########################################
if [ $EXECUTION_ENVIRONMENT_TAG == $DEFAULT_JDK_TAG ]; then
	## Tag default versions 
	docker buildx imagetools create --tag $REPOSITORY/dsjava:$DEFAULT_TAG $REPOSITORY/dsjava:$DEFAULT_JDK_TAG
	
	##### TAG LATEST #####
	if [ "$DEV" = false ] ; then
		docker buildx imagetools create --tag $REPOSITORY/dsjava $REPOSITORY/dsjava:$DEFAULT_NORMAL_TAG
		[[ -z "$TAG_SUFFIX" ]] && docker buildx imagetools create --tag $REPOSITORY/dsjava:"${TAG_SUFFIX//-}" $REPOSITORY/dsjava:$DEFAULT_TAG # alpine or slim tags
	else 
		docker buildx imagetools create --tag $REPOSITORY/dsjava:develop${TAG_SUFFIX} $REPOSITORY/dsjava:$DEFAULT_TAG
	fi
fi
if [ "$DEV" = true ] ; then 
	docker buildx imagetools create --tag $REPOSITORY/dsjava:develop.jdk${JAVA_VERSION}${TAG_SUFFIX} $REPOSITORY/dsjava:$EXECUTION_ENVIRONMENT_TAG
fi 
#################################################################################################

# Remove builder
if [ "$SHARE_BUILDERX" = "false" ]; then
  docker buildx rm $DOCKER_BUILDER
fi
printMsg " ===== Done! (in $n retries) ===== "




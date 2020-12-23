#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
REPOSITORY="bscdataclay"

source $BUILDDIR/../../common/config.sh
if [ -z $EXECUTION_ENVIRONMENT_TAG ]; then echo "ERROR: EXECUTION_ENVIRONMENT_TAG not defined. Aborting"; exit 1; fi

if [ "$SHARE_BUILDERX" = "false" ]; then
  source $BUILDDIR/../../common/prepare_docker_builder.sh
fi

# LOGICMODULE
pushd $BUILDDIR

echo "************* Pushing image named $REPOSITORY/logicmodule:$EXECUTION_ENVIRONMENT_TAG (retry $n) *************"
deploy docker buildx build $DOCKERFILE -t $REPOSITORY/logicmodule:$EXECUTION_ENVIRONMENT_TAG \
    --build-arg VERSION=$EXECUTION_ENVIRONMENT_TAG \
		--build-arg JDK=$JAVA_VERSION \
		--build-arg BASE_VERSION=$BASE_VERSION_TAG \
		--build-arg JAR_VERSION=$JAR_VERSION \
		--cache-to=type=registry,ref=bscdataclay/logicmodule:${EXECUTION_ENVIRONMENT_TAG}-buildxcache,mode=max \
	  --cache-from=type=registry,ref=bscdataclay/logicmodule:${EXECUTION_ENVIRONMENT_TAG}-buildxcache \
		--platform $PLATFORMS $DOCKER_PROGRESS \
		--push .
echo "************* $REPOSITORY/logicmodule:$EXECUTION_ENVIRONMENT_TAG IMAGE PUSHED! (in $n retries) *************"
popd 


######################################## tags ###########################################
if [ $EXECUTION_ENVIRONMENT_TAG == $DEFAULT_JDK_TAG ]; then
	## Tag default versions 
	docker buildx imagetools create --tag $REPOSITORY/logicmodule:$DEFAULT_TAG $REPOSITORY/logicmodule:$DEFAULT_JDK_TAG
	##### TAG LATEST #####
	if [ "$DEV" = false ] ; then
		docker buildx imagetools create --tag $REPOSITORY/logicmodule $REPOSITORY/logicmodule:$DEFAULT_NORMAL_TAG
		[[ ! -z "$TAG_SUFFIX" ]] && docker buildx imagetools create --tag $REPOSITORY/logicmodule:"${TAG_SUFFIX//-}" $REPOSITORY/logicmodule:$DEFAULT_TAG # alpine or slim tags
	else 
		docker buildx imagetools create --tag $REPOSITORY/logicmodule:develop${TAG_SUFFIX} $REPOSITORY/logicmodule:$DEFAULT_TAG
	fi
fi
if [ "$DEV" = true ] ; then 
	docker buildx imagetools create --tag $REPOSITORY/logicmodule:develop.jdk${JAVA_VERSION}${TAG_SUFFIX} $REPOSITORY/logicmodule:$EXECUTION_ENVIRONMENT_TAG
fi 
#################################################################################################

# Remove builder
if [ "$SHARE_BUILDERX" = "false" ]; then
  docker buildx rm $DOCKER_BUILDER
fi
printMsg " ===== Done! (in $n retries) ===== "




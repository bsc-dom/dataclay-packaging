#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

source $BUILDDIR/../../common/config.sh
if [ -z $EXECUTION_ENVIRONMENT_TAG ]; then echo "ERROR: EXECUTION_ENVIRONMENT_TAG not defined. Aborting"; exit 1; fi

pushd $BUILDDIR
if [ "$SHARE_BUILDER" = "false" ]; then
  docker build -f packager.Dockerfile -t bscdataclay/javaclay .
fi
JAVACLAY_CONTAINER=$(docker create --rm bscdataclay/javaclay)
docker cp $JAVACLAY_CONTAINER:/javaclay/target/dataclay-${JAR_VERSION}-shaded.jar ./dataclay.jar
docker rm $JAVACLAY_CONTAINER

deploy docker buildx build $DOCKERFILE -t bscdataclay/logicmodule:$EXECUTION_ENVIRONMENT_TAG \
    --build-arg VCS_REF=`git rev-parse --short HEAD` \
    --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
    --build-arg VERSION=$EXECUTION_ENVIRONMENT_TAG \
		--build-arg JDK=$JAVA_VERSION \
		--build-arg BASE_VERSION=$BASE_VERSION_TAG \
		--platform $PLATFORMS $DOCKER_PROGRESS \
		--push .
popd

######################################## tags ###########################################
CUR_DATE_TAG=$(date -u +"%Y%m%d")
if [ $EXECUTION_ENVIRONMENT_TAG == $DEFAULT_JDK_TAG ]; then
	## Tag default versions 
	docker buildx imagetools create --tag bscdataclay/logicmodule:$DEFAULT_TAG bscdataclay/logicmodule:$DEFAULT_JDK_TAG
	##### TAG LATEST #####
	if [ "$DEV" = false ] ; then
		docker buildx imagetools create --tag bscdataclay/logicmodule bscdataclay/logicmodule:$DEFAULT_NORMAL_TAG
		[[ ! -z "$TAG_SUFFIX" ]] && docker buildx imagetools create --tag bscdataclay/logicmodule:"${TAG_SUFFIX//-}" bscdataclay/logicmodule:$DEFAULT_TAG # alpine or slim tags
	else 
		docker buildx imagetools create --tag bscdataclay/logicmodule:develop${TAG_SUFFIX} bscdataclay/logicmodule:$DEFAULT_TAG
		docker buildx imagetools create --tag bscdataclay/logicmodule:dev${CUR_DATE_TAG}${TAG_SUFFIX} bscdataclay/logicmodule:$DEFAULT_TAG

	fi
fi
if [ "$DEV" = true ] ; then
	docker buildx imagetools create --tag bscdataclay/logicmodule:develop.jdk${JAVA_VERSION}${TAG_SUFFIX} bscdataclay/logicmodule:$EXECUTION_ENVIRONMENT_TAG
	docker buildx imagetools create --tag bscdataclay/logicmodule:dev${CUR_DATE_TAG}.jdk${JAVA_VERSION}${TAG_SUFFIX} bscdataclay/logicmodule:$EXECUTION_ENVIRONMENT_TAG
fi
#################################################################################################
printMsg " ===== Done! ===== "




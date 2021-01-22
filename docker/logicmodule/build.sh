#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BUILDDIR/../../common/config.sh
if [ -z $EXECUTION_ENVIRONMENT_TAG ]; then echo "ERROR: EXECUTION_ENVIRONMENT_TAG not defined. Aborting"; exit 1; fi
pushd $BUILDDIR
if [ "$SHARE_BUILDER" = "false" ]; then
  docker build -f packager.Dockerfile -t bscdataclay/javaclay .
fi
# LOGICMODULE
JAVACLAY_CONTAINER=$(docker create --rm bscdataclay/javaclay)
docker cp $JAVACLAY_CONTAINER:/javaclay/target/dataclay-${JAR_VERSION}-shaded.jar ./dataclay.jar
docker rm $JAVACLAY_CONTAINER

build docker $DOCKER_BUILDX_COMMAND build $DOCKERFILE \
       --build-arg VCS_REF="abc1234" \
       --build-arg BUILD_DATE="0000-00-00" \
       --build-arg VERSION=$EXECUTION_ENVIRONMENT_TAG \
			 --build-arg BASE_VERSION=$BASE_VERSION_TAG \
			 --build-arg JDK=$JAVA_VERSION \
			 -t ${REGISTRY}bscdataclay/logicmodule:$EXECUTION_ENVIRONMENT_TAG \
			  $BUILD_PLATFORM $DOCKER_COMMAND .
popd
	
######################################## default tags ###########################################
if [ $EXECUTION_ENVIRONMENT_TAG == $DEFAULT_JDK_TAG ]; then
	## Tag default versions
	docker tag bscdataclay/logicmodule:$DEFAULT_JDK_TAG bscdataclay/logicmodule:$DEFAULT_TAG

	# Tag latest
	if [ "$DEV" = false ] ; then
		docker tag bscdataclay/logicmodule:$DEFAULT_NORMAL_TAG bscdataclay/logicmodule
	  docker tag bscdataclay/logicmodule:$DEFAULT_TAG bscdataclay/logicmodule:"${TAG_SUFFIX//-}"
	else
		docker tag bscdataclay/logicmodule:$DEFAULT_TAG bscdataclay/logicmodule:develop${TAG_SUFFIX} #develop-slim, develop-alpine
	fi
fi
if [ "$DEV" = true ] ; then
  echo "docker tag ${REGISTRY}bscdataclay/logicmodule:$EXECUTION_ENVIRONMENT_TAG bscdataclay/logicmodule:develop.jdk${JAVA_VERSION}${TAG_SUFFIX}"
	docker tag bscdataclay/logicmodule:$EXECUTION_ENVIRONMENT_TAG bscdataclay/logicmodule:develop.jdk${JAVA_VERSION}${TAG_SUFFIX} #develop.jdk8-slim
fi

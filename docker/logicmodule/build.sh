#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
REPOSITORY="bscdataclay"
source $BUILDDIR/../../common/config.sh
if [ -z $EXECUTION_ENVIRONMENT_TAG ]; then echo "ERROR: EXECUTION_ENVIRONMENT_TAG not defined. Aborting"; exit 1; fi


if [ "$SHARE_BUILDER" = "false" ]; then
  # PACKAGE
  docker build -f packager.Dockerfile -t $REPOSITORY/javaclay .
fi


# LOGICMODULE
pushd $BUILDDIR
JAVACLAY_CONTAINER=$(docker create --rm $REPOSITORY/javaclay)
docker cp $JAVACLAY_CONTAINER:/javaclay/target/dataclay-${JAR_VERSION}-shaded.jar ./dataclay.jar
docker rm $JAVACLAY_CONTAINER

printMsg "Building image named $REPOSITORY/logicmodule:${EXECUTION_ENVIRONMENT_TAG}"
docker build $DOCKERFILE \
       --build-arg VCS_REF="abc1234" \
       --build-arg BUILD_DATE="0000-00-00" \
       --build-arg VERSION=$EXECUTION_ENVIRONMENT_TAG \
			 --build-arg BASE_VERSION=$BASE_VERSION_TAG \
			 --build-arg JDK=$JAVA_VERSION \
			 -t $REPOSITORY/logicmodule:$EXECUTION_ENVIRONMENT_TAG .
printMsg "$REPOSITORY/logicmodule:${EXECUTION_ENVIRONMENT_TAG} IMAGE DONE!"
popd 
	
######################################## default tags ###########################################
if [ $EXECUTION_ENVIRONMENT_TAG == $DEFAULT_JDK_TAG ]; then
	## Tag default versions 
	docker tag $REPOSITORY/logicmodule:$DEFAULT_JDK_TAG $REPOSITORY/logicmodule:$DEFAULT_TAG

	# Tag latest
	if [ "$DEV" = false ] ; then
		docker tag $REPOSITORY/logicmodule:$DEFAULT_NORMAL_TAG $REPOSITORY/logicmodule
	  docker tag $REPOSITORY/logicmodule:$DEFAULT_TAG $REPOSITORY/logicmodule:"${TAG_SUFFIX//-}"
	else 
		docker tag $REPOSITORY/logicmodule:$DEFAULT_TAG $REPOSITORY/logicmodule:develop${TAG_SUFFIX} #develop-slim, develop-alpine
	fi
fi
if [ "$DEV" = true ] ; then 
	docker tag $REPOSITORY/logicmodule:$EXECUTION_ENVIRONMENT_TAG $REPOSITORY/logicmodule:develop.jdk${JAVA_VERSION}${TAG_SUFFIX} #develop.jdk8-slim
fi

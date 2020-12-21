#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
REPOSITORY="bscdataclay"
source $BUILDDIR/../../common/config.sh
if [ -z $EXECUTION_ENVIRONMENT_TAG ]; then echo "ERROR: EXECUTION_ENVIRONMENT_TAG not defined. Aborting"; exit 1; fi

if [ "$PACKAGE_JAR" = "true" ]; then
	# CREATE DATACLAY JAR
	pushd $BUILDDIR/javaclay
	printMsg "Packaging dataclay.jar"
	mvn package -q -DskipTests=true >/dev/null
	printMsg "dataclay.jar created!"
	popd
fi

# LOGICMODULE
pushd $BUILDDIR
printMsg "Building image named $REPOSITORY/logicmodule:${EXECUTION_ENVIRONMENT_TAG}"
docker build --rm $DOCKERFILE \
       --build-arg VERSION=$EXECUTION_ENVIRONMENT_TAG \
			 --build-arg BASE_VERSION=$BASE_VERSION_TAG \
			 --build-arg JDK=$JAVA_VERSION \
			 --build-arg JAR_VERSION=$JAR_VERSION \
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

#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
REPOSITORY="bscdataclay"
source $BUILDDIR/../../common/config.sh
if [ -z $EXECUTION_ENVIRONMENT_TAG ]; then echo "ERROR: EXECUTION_ENVIRONMENT_TAG not defined. Aborting"; exit 1; fi
source $BUILDDIR/../../common/prepare_docker_builder.sh

if [ $PACKAGE_JAR == true ]; then 
	# CREATE DATACLAY JAR
	pushd $BUILDDIR/javaclay
	echo "Packaging dataclay.jar"
	mvn package -q -DskipTests=true >/dev/null
	echo "dataclay.jar created!"
	popd
fi

# LOGICMODULE
pushd $BUILDDIR
echo "************* Pushing image named $REPOSITORY/logicmodule:$EXECUTION_ENVIRONMENT_TAG *************"
docker buildx build -t $REPOSITORY/logicmodule:$EXECUTION_ENVIRONMENT_TAG \
		--build-arg JDK=$JAVA_VERSION \
		--build-arg BASE_VERSION=$BASE_VERSION_TAG \
		--build-arg LOCAL_JAR=$JAR_NAME \
		--platform $PLATFORMS \
		--cache-to=type=registry,ref=bscdataclay/logicmodule:buildxcache${EXECUTION_ENVIRONMENT},mode=max \
		--cache-from=type=registry,ref=bscdataclay/logicmodule:buildxcache${EXECUTION_ENVIRONMENT} \
		--push .
echo "************* $REPOSITORY/logicmodule:$EXECUTION_ENVIRONMENT_TAG IMAGE PUSHED! *************"
popd 


######################################## tags ###########################################
if [ $EXECUTION_ENVIRONMENT_TAG == $DEFAULT_JDK_TAG ]; then
	## Tag default versions 
	docker buildx imagetools create --tag $REPOSITORY/logicmodule:$DEFAULT_TAG $REPOSITORY/logicmodule:$DEFAULT_JDK_TAG
	##### TAG LATEST #####
	if [ "$DEV" = false ] ; then
		docker buildx imagetools create --tag $REPOSITORY/logicmodule $REPOSITORY/logicmodule:$DEFAULT_TAG
	else 
		docker buildx imagetools create --tag $REPOSITORY/logicmodule:develop $REPOSITORY/logicmodule:$DEFAULT_TAG
	fi
fi
if [ "$DEV" = true ] ; then 
	docker buildx imagetools create --tag $REPOSITORY/logicmodule:develop.jdk${JAVA_VERSION} $REPOSITORY/logicmodule:$EXECUTION_ENVIRONMENT_TAG
fi 
#################################################################################################

# Remove builder
docker buildx rm $DOCKER_BUILDER
printMsg " ===== Done! ====="




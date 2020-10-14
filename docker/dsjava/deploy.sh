#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
REPOSITORY="bscdataclay"
source $BUILDDIR/../../common/config.sh
if [ -z $EXECUTION_ENVIRONMENT_TAG ]; then echo "ERROR: EXECUTION_ENVIRONMENT_TAG not defined. Aborting"; exit 1; fi
source $BUILDDIR/../../common/prepare_docker_builder.sh

if [ $PACKAGE_JAR == true ]; then 
	# CREATE DATACLAY JAR
	pushd $BUILDDIR/../logicmodule/javaclay
	mvn package -DskipTests=true $PACKAGE_PROFILE >/dev/null
	popd
fi

# DSJAVA
pushd $BUILDDIR
echo "************* Building image named $REPOSITORY/dsjava:$EXECUTION_ENVIRONMENT_TAG *************"
docker buildx build $DOCKERFILE -t $REPOSITORY/dsjava:$EXECUTION_ENVIRONMENT_TAG \
		--build-arg LOGICMODULE_VERSION=$EXECUTION_ENVIRONMENT_TAG \
		--platform $PLATFORMS \
		--cache-to=type=registry,ref=bscdataclay/dsjava:${EXECUTION_ENVIRONMENT_TAG}-buildxcache,mode=max \
		--cache-from=type=registry,ref=bscdataclay/dsjava:${EXECUTION_ENVIRONMENT_TAG}-buildxcache \
		--push .
echo "************* $REPOSITORY/dsjava:$EXECUTION_ENVIRONMENT_TAG DONE! *************"
popd 

######################################## tags ###########################################
if [ $EXECUTION_ENVIRONMENT_TAG == $DEFAULT_JDK_TAG ]; then
	## Tag default versions 
	docker buildx imagetools create --tag $REPOSITORY/dsjava:$DEFAULT_TAG $REPOSITORY/dsjava:$DEFAULT_JDK_TAG
	
	##### TAG LATEST #####
	if [ "$DEV" = false ] ; then
		docker buildx imagetools create --tag $REPOSITORY/dsjava $REPOSITORY/dsjava:$DEFAULT_TAG
	else 
		docker buildx imagetools create --tag $REPOSITORY/dsjava:develop${TAG_SUFFIX} $REPOSITORY/dsjava:$DEFAULT_TAG
	fi
fi
if [ "$DEV" = true ] ; then 
	docker buildx imagetools create --tag $REPOSITORY/dsjava:develop.jdk${JAVA_VERSION}${TAG_SUFFIX} $REPOSITORY/dsjava:$EXECUTION_ENVIRONMENT_TAG
fi 
#################################################################################################

# Remove builder
docker buildx rm $DOCKER_BUILDER
printMsg " ===== Done! ====="




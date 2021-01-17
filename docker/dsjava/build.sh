#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
REPOSITORY="bscdataclay"
source $BUILDDIR/../../common/config.sh
if [ -z $EXECUTION_ENVIRONMENT_TAG ]; then echo "ERROR: EXECUTION_ENVIRONMENT_TAG not defined. Aborting"; exit 1; fi

# DSJAVA
pushd $BUILDDIR
printMsg "Building image named $REPOSITORY/dsjava:$EXECUTION_ENVIRONMENT_TAG"
docker build $DOCKERFILE \
         --build-arg VCS_REF="abc1234" \
         --build-arg BUILD_DATE="0000-00-00" \
         --build-arg VERSION=$EXECUTION_ENVIRONMENT_TAG \
			   --build-arg LOGICMODULE_VERSION=$EXECUTION_ENVIRONMENT_TAG \
			   -t $REPOSITORY/dsjava:$EXECUTION_ENVIRONMENT_TAG .
printMsg " $REPOSITORY/dsjava:$EXECUTION_ENVIRONMENT_TAG DONE!"
popd 
######################################## default tags ###########################################
if [ $EXECUTION_ENVIRONMENT_TAG == $DEFAULT_JDK_TAG ]; then
	## Tag default versions 
	docker tag $REPOSITORY/dsjava:$DEFAULT_JDK_TAG $REPOSITORY/dsjava:$DEFAULT_TAG
		
	if [ "$DEV" = false ] ; then
	  docker tag $REPOSITORY/dsjava:$DEFAULT_NORMAL_TAG $REPOSITORY/dsjava
	  docker tag $REPOSITORY/dsjava:$DEFAULT_TAG $REPOSITORY/dsjava:"${TAG_SUFFIX//-}"
	else 
		docker tag $REPOSITORY/dsjava:$DEFAULT_TAG $REPOSITORY/dsjava:develop${TAG_SUFFIX} #develop-slim, develop-alpine
	fi
fi
if [ "$DEV" = true ] ; then 
	docker tag $REPOSITORY/dsjava:$EXECUTION_ENVIRONMENT_TAG $REPOSITORY/dsjava:develop.jdk${JAVA_VERSION}${TAG_SUFFIX} #develop.jdk11-slim
fi
#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
REPOSITORY="bscdataclay"
source $BUILDDIR/../../common/config.sh
if [ -z $EXECUTION_ENVIRONMENT_TAG ]; then echo "ERROR: EXECUTION_ENVIRONMENT_TAG not defined. Aborting"; exit 1; fi

# CREATE DATACLAY JAR
pushd $BUILDDIR/../logicmodule/javaclay
mvn package -DskipTests=true
popd

# DSJAVA
pushd $BUILDDIR
printMsg "Building image named $REPOSITORY/dsjava:$EXECUTION_ENVIRONMENT_TAG"
docker build --build-arg LOGICMODULE_VERSION=$EXECUTION_ENVIRONMENT_TAG -t $REPOSITORY/dsjava:$EXECUTION_ENVIRONMENT_TAG .
printMsg " $REPOSITORY/dsjava:$EXECUTION_ENVIRONMENT_TAG DONE!"
popd 

######################################## default tags ###########################################
if [ $EXECUTION_ENVIRONMENT_TAG == $DEFAULT_JDK_TAG ]; then
	## Tag default versions 
	docker tag $REPOSITORY/dsjava:$DEFAULT_JDK_TAG $REPOSITORY/dsjava:$DEFAULT_TAG
	# Tag latest
	if [ "$DEV" = false ] ; then
		docker tag $REPOSITORY/dsjava:$DEFAULT_TAG $REPOSITORY/dsjava
	fi 
fi


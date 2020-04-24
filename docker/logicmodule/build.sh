#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
REPOSITORY="bscdataclay"
source $BUILDDIR/../../common/config.sh
if [ -z $EXECUTION_ENVIRONMENT_TAG ]; then echo "ERROR: EXECUTION_ENVIRONMENT_TAG not defined. Aborting"; exit 1; fi

# CREATE DATACLAY JAR
pushd $BUILDDIR/javaclay
printMsg "Packaging dataclay.jar"
mvn package -q -DskipTests=true >/dev/null
printMsg "dataclay.jar created!"
popd

# LOGICMODULE
pushd $BUILDDIR
printMsg "Building image named $REPOSITORY/logicmodule:$EXECUTION_ENVIRONMENT_TAG"
docker build --build-arg BASE_VERSION=$BASE_VERSION_TAG --build-arg JDK=$JAVA_VERSION --build-arg LOCAL_JAR=$JAR_NAME -t $REPOSITORY/logicmodule:$EXECUTION_ENVIRONMENT_TAG .
printMsg "$REPOSITORY/logicmodule:$EXECUTION_ENVIRONMENT_TAG IMAGE DONE!"
popd 
######################################## default tags ###########################################
if [ $EXECUTION_ENVIRONMENT_TAG == $DEFAULT_JDK_TAG ]; then
	## Tag default versions 
	docker tag $REPOSITORY/logicmodule:$DEFAULT_JDK_TAG $REPOSITORY/logicmodule:$DEFAULT_TAG
	# Tag latest
	docker tag $REPOSITORY/logicmodule:$DEFAULT_TAG $REPOSITORY/logicmodule 
fi


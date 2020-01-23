#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
set -e
TRACING=false
DEBUG=false
ARGS=""
################################## OPTIONS #############################################
while [[ $# -gt 0 ]]; do
    key="$1"
	case $key in
	--tracing)
		TRACING=true
		shift
        ;;
	--debug)
		DEBUG=true
		shift
        ;;
    *)
    	ARGS="$ARGS $key"
 		shift
        ;;
    esac
done

### ========================== EXTRAE ============================= ##
if [ "$TRACING" = true ] ; then
	# find aspectj version
	ASPECTJ_VERSION=`ls $HOME/.m2/repository/org/aspectj/aspectjweaver/`
	ARGS="-javaagent:${HOME}/.m2/repository/org/aspectj/aspectjweaver/${ASPECTJ_VERSION}/aspectjweaver-${ASPECTJ_VERSION}.jar -Dorg.aspectj.weaver.showWeaveInfo=true $ARGS"
fi

### ========================== LOGGING ============================= ##
if [ "$DEBUG" = true ] ; then
	ARGS="-Dlog4j.configurationFile=$DATACLAY_LOG_CONFIG $ARGS"
else 
	ARGS="-Dorg.apache.logging.log4j.simplelog.StatusLogger.level=OFF $ARGS"	
fi

### ========================== ENTRYPOINT ============================= ##
cmd="java -cp $DATACLAY_JAR -Dcom.google.inject.internal.cglib.$experimental_asm7=true $ARGS"
export JDK_JAVA_OPTIONS="--add-opens java.base/java.lang=ALL-UNNAMED"
if [ "$DEBUG" = true ] ; then
	echo $cmd
fi
echo $cmd
eval $cmd

if [ "$TRACING" = true ] ; then 
	mkdir -p trace
	mpi2prv -f TRACE.mpits -o ./trace/dctrace.prv
fi

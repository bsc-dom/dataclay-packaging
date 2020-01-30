#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
set -e
TRACING=false
DEBUG=false
ARGS=""
DEFINED_CLASSPATH_SET=false
DEFINED_CLASSPATH=""
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
    --classpath)
    	shift
    	DEFINED_CLASSPATH_SET=true
		DEFINED_CLASSPATH=$1
		shift
        ;;
    -cp)
        shift
    	DEFINED_CLASSPATH_SET=true
		DEFINED_CLASSPATH=$1
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
	ARGS="-javaagent:/usr/share/java/aspectjweaver.jar -Dorg.aspectj.weaver.showWeaveInfo=true $ARGS"
fi

### ========================== LOGGING ============================= ##
if [ "$DEBUG" = true ] ; then
	ARGS="-Dlog4j.configurationFile=$DATACLAY_LOG_CONFIG $ARGS"
else 
	ARGS="-Dorg.apache.logging.log4j.simplelog.StatusLogger.level=OFF $ARGS"	
fi

### ========================== CLASSPATH ============================= ##
if [ "$DEFINED_CLASSPATH_SET" = true ] ; then
	ARGS="-cp $DEFINED_CLASSPATH $ARGS"
else 
	ARGS="-cp $DATACLAY_JAR $ARGS"	
fi

### ========================== ENTRYPOINT ============================= ##
cmd="exec java -Dcom.google.inject.internal.cglib.$experimental_asm7=true $ARGS"
export JDK_JAVA_OPTIONS="--add-opens java.base/java.lang=ALL-UNNAMED"
if [ "$DEBUG" = true ] ; then
	echo $cmd
fi
echo $cmd 
eval $cmd 
wait $!

if [ "$TRACING" = true ] ; then 
	mkdir -p trace
	mpi2prv -f TRACE.mpits -o ./trace/dctrace.prv
fi

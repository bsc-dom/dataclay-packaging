#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
TRACING=false
DEBUG=false
ARGS=""
DEFINED_CLASSPATH_SET=false
DEFINED_CLASSPATH=""
SERVICE=false
################################## SIGNALING #############################################
_term() { 
	echo "Caught SIGTERM signal!" 
	kill -TERM "$service_pid"
	wait "$service_pid"
    if [ $TRACING == true ] && [ $SERVICE == false ] ; then 
		mkdir -p trace
		mpi2prv -f TRACE.mpits -o ./trace/dctrace.prv
 	fi
	echo "ENTRYPOINT SHUTDOWN FINISHED"
}

trap _term SIGTERM

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
    --service)
    	SERVICE=true
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
if [ $TRACING == true ] ; then
	ARGS="-javaagent:/usr/share/java/aspectjweaver.jar -Daj.weaving.verbose=false -Dorg.aspectj.weaver.showWeaveInfo=false $ARGS"
fi

### ========================== LOGGING ============================= ##
if [ $DEBUG == true ] ; then
	ARGS="-Dlog4j.configurationFile=$DATACLAY_LOG_CONFIG $ARGS"
else 
	ARGS="-Dorg.apache.logging.log4j.simplelog.StatusLogger.level=OFF $ARGS"	
fi

### ========================== CLASSPATH ============================= ##
if [ $DEFINED_CLASSPATH_SET == true ] ; then
	export CLASSPATH=${DEFINED_CLASSPATH}
fi

### ========================== ENTRYPOINT ============================= ##
export JDK_JAVA_OPTIONS="--add-opens java.base/java.lang=ALL-UNNAMED"

java -Dcom.google.inject.internal.cglib.$experimental_asm7=true $ARGS &
service_pid=$! 
wait "$service_pid"

if [ $TRACING == true ] && [ $SERVICE == false ] ; then 
	mkdir -p trace
	mpi2prv -no-syn -f TRACE.mpits -o ./trace/dctrace.prv
fi
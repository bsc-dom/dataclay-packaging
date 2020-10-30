#!/bin/bash
TRACING=false
EXEC_ARGS_PROVIDED=false
DEBUG=false
EXEC_ARGS=""
ARGS=""
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

trap _term TERM
trap _term INT

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
    *)
    	if [[ "$key" != -D* ]]; then
    		if [ "$EXEC_ARGS_PROVIDED" = false ] ; then
				EXEC_ARGS_PROVIDED=true
	    		EXEC_ARGS="$key"  	
	    	else 
	    		EXEC_ARGS="$EXEC_ARGS $key"  	
	    	fi
	    else 
	    	ARGS="$ARGS $key"
	    fi
 		shift
        ;;
    esac
done

### ========================== EXTRAE ============================= ##
if [ $TRACING == true ] ; then
	# find aspectj version
	export MAVEN_OPTS="-javaagent:/usr/share/java/aspectjweaver.jar -Dorg.aspectj.weaver.showWeaveInfo=false"
fi

### ========================== LOGGING ============================= ##
if [ $DEBUG == true ] ; then
	ARGS="$ARGS -Dlog4j.configurationFile=$DATACLAY_LOG_CONFIG"
else 
	ARGS="$ARGS -q -Dorg.apache.logging.log4j.simplelog.StatusLogger.level=OFF"	
fi

### ========================== ENTRYPOINT ============================= ##


export JDK_JAVA_OPTIONS="--add-opens java.base/java.lang=ALL-UNNAMED"
if [ $EXEC_ARGS_PROVIDED == true ] ; then
	mvn exec:java $ARGS -Dexec.cleanupDaemonThreads=false -Dexec.args="$EXEC_ARGS" -Dcom.google.inject.internal.cglib.$experimental_asm7=true &
else
	mvn exec:java $ARGS -Dexec.cleanupDaemonThreads=false -Dcom.google.inject.internal.cglib.$experimental_asm7=true &
fi

service_pid=$! 
wait "$service_pid"
if [ $TRACING == true ] && [ $SERVICE == false ] ; then 
	mkdir -p trace
	mpi2prv -no-syn -f TRACE.mpits -o ./trace/dctrace.prv
fi

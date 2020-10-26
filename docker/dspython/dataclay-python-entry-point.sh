#!/bin/sh -e
TRACING="false"
EXEC_ARGS_PROVIDED="false"
EXEC_ARGS=""
DEBUG="false"
SERVICE="false"
################################## SIGNALING #############################################
_term() { 
	echo "Caught SIGTERM signal!" 
	kill -TERM "$service_pid"
	wait "$service_pid"
	if [ $TRACING = "true" ] && [ $SERVICE = "false" ] ; then 
		mkdir -p trace
		mpi2prv -f TRACE.mpits -o ./trace/dctrace.prv
 	fi
	echo "ENTRYPOINT SHUTDOWN FINISHED"
}

trap _term TERM
trap _term INT
################################## OPTIONS #############################################
while [ $# -gt 0 ]; do
    key="$1"
	case $key in
	--tracing)
		TRACING="true"
		shift
        ;;
	--debug)
		DEBUG="true"
		shift
        ;;
    --service)
    	SERVICE="true"
    	shift
    	;;
    *)
    	if [ "$EXEC_ARGS_PROVIDED" = "false" ] ; then
			EXEC_ARGS_PROVIDED="true"
	    	EXEC_ARGS="$key"  	
	    else 
	    	EXEC_ARGS="$EXEC_ARGS $key"  	
	    fi
 		shift
        ;;
    esac
done

### ========================== LOGGING ============================= ##
if [ $DEBUG = "true" ] ; then
	export DEBUG=True
fi

### ========================== ENTRYPOINT ============================= ##
python $EXEC_ARGS &
service_pid=$! 
wait "$service_pid"
if [ $TRACING = "true" ] && [ $SERVICE = "false" ] ; then 
	mkdir -p trace
	mpi2prv -no-syn -f TRACE.mpits -o ./trace/dctrace.prv
fi
#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
set -e
TRACING=false
EXEC_ARGS_PROVIDED=false
EXEC_ARGS=""
DEBUG=false

################################## SIGNALING #############################################
_term() { 
	echo "Caught SIGTERM signal!" 
	kill -TERM "$service"
	wait "$service"
  	if [ "$TRACING" = true ] ; then 
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
    *)
    	if [ "$EXEC_ARGS_PROVIDED" = false ] ; then
			EXEC_ARGS_PROVIDED=true
	    	EXEC_ARGS="$key"  	
	    else 
	    	EXEC_ARGS="$EXEC_ARGS $key"  	
	    fi
 		shift
        ;;
    esac
done

### ========================== LOGGING ============================= ##
if [ "$DEBUG" = true ] ; then
	export DEBUG=True
fi

### ========================== ENTRYPOINT ============================= ##

python $EXEC_ARGS &
service=$! 
wait "$service"

if [ "$TRACING" = true ] ; then 
	mkdir -p trace
	mpi2prv -f TRACE.mpits -o ./trace/dctrace.prv
fi
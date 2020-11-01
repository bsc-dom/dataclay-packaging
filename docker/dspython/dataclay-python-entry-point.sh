#!/bin/sh -e
TRACING="false"
EXEC_ARGS_PROVIDED="false"
EXEC_ARGS=""
DEBUG="false"
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
exec python -u $EXEC_ARGS
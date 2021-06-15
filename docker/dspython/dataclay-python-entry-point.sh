#!/bin/sh -e
TRACING="false"
EXEC_ARGS_PROVIDED="false"
EXEC_ARGS=""
DEBUG="false"
#ignore jvm args
JVM_ARGS=""
################################## OPTIONS #############################################
while [ $# -gt 0 ]; do
    key="$1"
	case $key in
    --tracing)
      TRACING="true"
      shift
      ;;
    "-X"*)
      JVM_ARGS="$JVM_ARGS $key"
      shift
      ;;
    "-D"*)
      JVM_ARGS="$JVM_ARGS $key"
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

### ========================== EXTRA LIBRARIES ============================= ##
if [ ! -z ${PYCLAY_LIBS+x} ]; then
  if [ ! -z ${PYPI_URL+x} ]; then
    pip install -i $PYPI_URL $PYCLAY_LIBS
  else
    pip install $PYCLAY_LIBS
  fi
fi

### ========================== ENTRYPOINT ============================= ##
exec python -u $EXEC_ARGS
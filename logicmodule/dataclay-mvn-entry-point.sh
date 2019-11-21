#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
set -e
TRACING=false
EXEC_ARGS_PROVIDED=false
DEBUG=false
EXEC_ARGS=""
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
if [ "$TRACING" = true ] ; then
	# find aspectj version
	ASPECTJ_VERSION=`ls $HOME/.m2/repository/org/aspectj/aspectjweaver/`
	export MAVEN_OPTS="-javaagent:${HOME}/.m2/repository/org/aspectj/aspectjweaver/${ASPECTJ_VERSION}/aspectjweaver-${ASPECTJ_VERSION}.jar -Dorg.aspectj.weaver.showWeaveInfo=true"
fi

### ========================== LOGGING ============================= ##
if [ "$DEBUG" = true ] ; then
	ARGS="$ARGS -Dlog4j.configurationFile=$DATACLAY_LOG_CONFIG"
else 
	ARGS="$ARGS -q -Dorg.apache.logging.log4j.simplelog.StatusLogger.level=OFF"	
fi

### ========================== ENTRYPOINT ============================= ##
if [ "$EXEC_ARGS_PROVIDED" = true ] ; then
	cmd="mvn exec:java -q $ARGS -Dexec.cleanupDaemonThreads=false -Dexec.args=\"$EXEC_ARGS\" -Dcom.google.inject.internal.cglib.$experimental_asm7=true"
else
	cmd="mvn exec:java $ARGS -Dexec.cleanupDaemonThreads=false -Dcom.google.inject.internal.cglib.$experimental_asm7=true"
fi

export JDK_JAVA_OPTIONS="--add-opens java.base/java.lang=ALL-UNNAMED"
if [ "$DEBUG" = true ] ; then
	echo $cmd
fi
eval $cmd

if [ "$TRACING" = true ] ; then 
	mkdir -p trace
	mpi2prv -f TRACE.mpits -o ./trace/dctrace.prv
fi

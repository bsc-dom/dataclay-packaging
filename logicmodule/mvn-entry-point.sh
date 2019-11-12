#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
set -e
TRACING=false
EXEC_ARGS_PROVIDED=false
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

### ========================== ENTRYPOINT ============================= ##
if [ "$EXEC_ARGS_PROVIDED" = true ] ; then
	cmd="mvn exec:java -q -Dlog4j.configurationFile=$LOG4J_CLASSPATH $ARGS -Dexec.cleanupDaemonThreads=false -Dexec.args=\"$EXEC_ARGS\""
else
	cmd="mvn exec:java -q -Dlog4j.configurationFile=$LOG4J_CLASSPATH $ARGS -Dexec.cleanupDaemonThreads=false"
fi
#export JDK_JAVA_OPTIONS=--add-opens java.base/java.lang=com.google.guice
echo $cmd
eval $cmd

if [ "$TRACING" = true ] ; then 
	mkdir -p trace
	mpi2prv -f TRACE.mpits -o ./trace/dctrace.prv
fi

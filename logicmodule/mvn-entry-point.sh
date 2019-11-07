#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
set -e
EXTRAE=false
EXEC_ARGS_PROVIDED=false
EXEC_ARGS=""
ARGS=""
################################## OPTIONS #############################################
while [[ $# -gt 0 ]]; do
    key="$1"
	case $key in
	--extrae)
		# Checking Java version 
		version=$("java" -version 2>&1 | awk -F '"' '/version/ {print $2}' | awk -F '.' '{print $1}')
		if (("$version" > "9")); then       
			echo "Cannot run with extrae aspects since Java version is > 1.9"
			exit 1
		fi
		EXTRAE=true
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
if [ "$EXTRAE" = true ] ; then
	# find aspectj version
	ASPECTJ_VERSION=`ls $HOME/.m2/repository/org/aspectj/aspectjweaver/`
	export MAVEN_OPTS="-javaagent:${HOME}/.m2/repository/org/aspectj/aspectjweaver/${ASPECTJ_VERSION}/aspectjweaver-${ASPECTJ_VERSION}.jar -Dorg.aspectj.weaver.showWeaveInfo=true"
	echo MAVEN_OPTS=$MAVEN_OPTS
fi

### ========================== ENTRYPOINT ============================= ##
if [ "$EXEC_ARGS_PROVIDED" = true ] ; then
	cmd="mvn exec:java -q -Dlog4j.configurationFile=$LOG4J_CLASSPATH $ARGS -Dexec.cleanupDaemonThreads=false -Dexec.args=\"$EXEC_ARGS\""
else
	cmd="mvn exec:java -q -Dlog4j.configurationFile=$LOG4J_CLASSPATH $ARGS -Dexec.cleanupDaemonThreads=false"
fi
echo $cmd
eval $cmd

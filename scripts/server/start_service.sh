#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
EXTRAE_REQUIRED_JAVA_VERSION=8
set -e


#### Check environment variables
if [ -z "${SERVICE}" ]; then
    echo "SERVICE environment variable is unset or set to the empty string"
    exit -1
fi
if [ -z "${DATACLAY_JAR}" ]; then
    echo "DATACLAY_JAR environment variable is unset or set to the empty string"
    exit -1
fi
if [ -z "${DATACLAY_LIBPATH}" ]; then
    echo "DATACLAY_LIBPATH environment variable is unset or set to the empty string"
    exit -1
fi
if [ -z "${LOG4J_CLASSPATH}" ]; then
    echo "LOG4J_CLASSPATH environment variable is unset or set to the empty string"
    exit -1
fi

echo "Starting service $SERVICE	..."
# ToDo check environment variables
################################## OPTIONS #############################################
while [[ $# -gt 0 ]]; do
    key="$1"
	case $key in
	--extrae)
		# extrae means to apply extrae aspects which are located by default in $DEFAULT_EXTRAE_ASPECTS_JAR
		ASPECTS_JAR_FILE=$DEFAULT_EXTRAE_ASPECTS_JAR
		if [ -z "${DEFAULT_EXTRAE_ASPECTS_JAR}" ]; then
		    echo "DEFAULT_EXTRAE_ASPECTS_JAR environment variable is unset or set to the empty string"
		    echo "Compile extrae aspects before continue. Otherwise use --apply-aspects to apply another aspects jar in another location"
		    exit -1
		fi
		APPLY_ASPECTS_EXTRAE=true
		APPLY_ASPECTS=true
		shift
        ;;
	--apply-aspects)
		# apply aspects
		shift 
		if [[ $# -ne 1 ]]; then 
    		#usage
    		exit -1
    	fi
		ASPECTS_JAR_FILE=$1
		APPLY_ASPECTS=true
		shift
        ;;
    -h|--help)
        #usage
        exit 0
        ;;
    *)
        echo "  ERROR: Bad option $key"
        shift
        #usage   # unknown option
        exit 1
        ;;
    esac
done

### ========================== ASPECTS ============================= ##
if [ "$APPLY_ASPECTS" = true ] ; then
	if [ "$APPLY_ASPECTS_EXTRAE" = true ] ; then	
		# Checking Java version 
		version=$("java" -version 2>&1 | awk -F '"' '/version/ {print $2}' | awk -F '.' '{print $1}')
		if (("$version" > "9")); then       
			echo "Cannot run with extrae aspects since Java version is > 1.9"
			exit 1
		fi
	fi
	if [ -f "$ASPECTS_JAR_FILE" ]; then 
		if [ -z "${ASPECTJ_WEAVER}" ]; then
			echo "ASPECTJ_WEAVER environment variable is unset or set to the empty string."
		    exit -1
		fi
		
		java -javaagent:$ASPECTJ_WEAVER -Daj.weaving.verbose=true \
					-Dorg.aspectj.weaver.showWeaveInfo=true \
					-Dlog4j.configurationFile=$LOG4J_CLASSPATH \
					-cp ${ASPECTS_JAR_FILE}:${DATACLAY_JAR}:$DATACLAY_LIBPATH/* $SERVICE
	else
		echo "ERROR: $ASPECTS_JAR_FILE not found"
		exit 1
	fi
### ========================== SERVICE ============================= ##
else 	
	java -Dlog4j.configurationFile=$LOG4J_CLASSPATH -cp $DATACLAY_JAR:$DATACLAY_LIBPATH/* $SERVICE	
fi 

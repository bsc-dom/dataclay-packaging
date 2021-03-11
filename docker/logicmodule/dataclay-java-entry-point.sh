#!/bin/sh
TRACING="false"
DEBUG="false"
ARGS=""
DEFINED_CLASSPATH_SET="false"
DEFINED_CLASSPATH=""
VISUALVM="false"
JVM_ARGS=""
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
    "-X"*)
      JVM_ARGS="$JVM_ARGS $key"
      shift
      ;;
    "-D"*)
      JVM_ARGS="$JVM_ARGS $key"
      shift
      ;;
    --visualvm)
      VISUALVM="true"
      shift
      ;;
    --classpath)
    	shift
    	DEFINED_CLASSPATH_SET="true"
		  DEFINED_CLASSPATH=$1
		  shift
      ;;
    -cp)
      shift
    	DEFINED_CLASSPATH_SET="true"
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
if [ $TRACING = "true" ] ; then
  mkdir -p trace
	ARGS="-javaagent:/usr/share/java/aspectjweaver.jar -Daj.weaving.verbose=false -Dorg.aspectj.weaver.showWeaveInfo=false $ARGS"
fi

### ========================== LOGGING ============================= ##
if [ $DEBUG = "true" ] ; then
  export CHECK_LOG4J_DEBUG=true
	ARGS="-Dlog4j.configurationFile=$DATACLAY_LOG_CONFIG $ARGS"
else 
	ARGS="-Dorg.apache.logging.log4j.simplelog.StatusLogger.level=OFF $ARGS"	
fi


if [ $VISUALVM = "true" ] ; then
  ARGS="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=9010 -Dcom.sun.management.jmxremote.local.only=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false $ARGS"
fi
### ========================== CLASSPATH ============================= ##
export THE_CLASSPATH="$DATACLAY_JAR:$CLASSPATH"
if [ $DEFINED_CLASSPATH_SET = "true" ] ; then
	export THE_CLASSPATH=${DEFINED_CLASSPATH}
fi

### ========================== ENTRYPOINT ============================= ##
export JDK_JAVA_OPTIONS="--add-opens java.base/java.lang=ALL-UNNAMED"
# -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap $DATACLAY_JVM_OPTIONS
exec java -Dcom.google.inject.internal.cglib.$experimental_asm7=true $JVM_ARGS -cp $THE_CLASSPATH $ARGS
#!/bin/sh
set -x
set -e
DEBUG="false"
ARGS=""
################################## OPTIONS #############################################
while [ $# -gt 0 ]; do
    key="$1"
	case $key in
    --debug)
      ARGS="$ARGS $key"
      DEBUG="true"
      shift
      ;;
    --wait-for-python-ds)
      shift
      NUM_PYTHON_DS=$1
      shift
      ;;
    --wait-for-java-ds)
      shift
      NUM_JAVA_DS=$1
      shift
      ;;
    *)
    	ARGS="$ARGS $key"
 		  shift
      ;;
    esac
done

########################### create cfgfiles ###########################
echo "ARGS=$ARGS"

printf "HOST=${LOGICMODULE_HOST}\nTCPPORT=${LOGICMODULE_PORT_TCP}" > ${DATACLAYCLIENTCONFIG}

######################################################

# Wait for dataclay to be alive (max retries 10 and 5 seconds per retry)
dataclaycmd WaitForDataClayToBeAlive 10 5 ${ARGS}
if [ ! -z $NUM_JAVA_DS ]; then
  dataclaycmd WaitForBackends java $NUM_JAVA_DSç
fi
if [ ! -z $NUM_PYTHON_DS ]; then
  dataclaycmd WaitForBackends python $NUM_PYTHON_DS
fi

# Register account
dataclaycmd NewAccount ${USER} ${PASS} ${ARGS}

# Register datacontract
dataclaycmd NewDataContract ${USER} ${PASS} ${DATASET} ${USER} ${ARGS}

########################### prepare git ###########################

mkdir -p ${DC_SHARED_VOLUME}/models
if [ ! -z $GIT_JAVA_MODELS_URLS ] || [ ! -z $GIT_PYTHON_MODELS_URLS ]; then
    # install git if needed
  if ! command -v git &> /dev/null
  then
      if ! command -v apk &> /dev/null
      then
        apt-get update && apt-get install --no-install-recommends -y --allow-unauthenticated git
      else
        apk --update add git
      fi
  fi
fi

########################### java git models ###########################
i=1
num_model=1
for GIT_JAVA_MODEL in $GIT_JAVA_MODELS_URLS; do
  GIT_JAVA_MODEL_PATH=$(echo "$GIT_JAVA_MODELS_PATHS" | cut -d\  -f${i})
  MODEL_DIR=${DC_SHARED_VOLUME}/models/model${num_model}/
  if [ ! -d "$MODEL_DIR" ]; then
    git clone $GIT_JAVA_MODEL ${DC_SHARED_VOLUME}/models/model${num_model}/
  else
    echo "!! WARNING: Model already found at ${DC_SHARED_VOLUME}/models/model${num_model}/. Using already cloned model"
  fi
  JAVA_MODELS_PATH="$JAVA_MODELS_PATH ${DC_SHARED_VOLUME}/models/model${num_model}/${GIT_JAVA_MODEL_PATH}"
  i=$(expr ${i} + 1)
  num_model=$(expr ${num_model} + 1)
done
########################### python git models ###########################
i=1
for GIT_PYTHON_MODEL in $GIT_PYTHON_MODELS_URLS; do
  GIT_PYTHON_MODEL_PATH=$(echo "$GIT_PYTHON_MODELS_PATHS" | cut -d\  -f${i})
  MODEL_DIR=${DC_SHARED_VOLUME}/models/model${num_model}/
  if [ ! -d "$MODEL_DIR" ]; then
    git clone $GIT_PYTHON_MODEL ${DC_SHARED_VOLUME}/models/model${num_model}/
  else
    echo "!! WARNING: Model already found at ${DC_SHARED_VOLUME}/models/model${num_model}/. Using already cloned model"
  fi
  PYTHON_MODELS_PATH="$PYTHON_MODELS_PATH ${DC_SHARED_VOLUME}/models/model${num_model}/${GIT_PYTHON_MODEL_PATH}"
  i=$(expr ${i} + 1)
  num_model=$(expr ${num_model} + 1)
done

########################### java model ###########################

i=1
for JAVA_MODEL in $JAVA_MODELS_PATH; do

  # install maven if needed
  if ! command -v mvn &> /dev/null
  then
      if ! command -v apk &> /dev/null
      then
        apt-get update && apt-get install --no-install-recommends -y --allow-unauthenticated maven
      else
        apk --update add maven
      fi
  fi
  # Register namespace
  JAVA_NAMESPACE=$(echo "$JAVA_NAMESPACES" | cut -d\  -f${i})

  # Register model
  cd ${JAVA_MODEL} && mvn package
  dataclaycmd NewModel ${USER} ${PASS} ${JAVA_NAMESPACE} ${JAVA_MODEL}/target/classes java ${ARGS}

  # Get contract ID for Java namespace
  CONTRACTID=`java -cp $DATACLAY_JAR es.bsc.dataclay.tool.AccessNamespace ${USER} ${PASS} ${JAVA_NAMESPACE} | tail -1`
  echo "${CONTRACTID}" > ${DC_SHARED_VOLUME}/${JAVA_NAMESPACE}_contractid

  i=$(expr ${i} + 1)

done

########################### python models ###########################

i=1
# Register python models
for PYTHON_MODEL in $PYTHON_MODELS_PATH; do

  # Register namespace
  PYTHON_NAMESPACE=$(echo "$PYTHON_NAMESPACES" | cut -d\  -f${i})

  # Register model
  dataclaycmd NewModel ${USER} ${PASS} ${PYTHON_NAMESPACE} ${PYTHON_MODEL} python ${ARGS}

  # Get contract ID for Python namespace
  CONTRACTID=`java -cp $DATACLAY_JAR es.bsc.dataclay.tool.AccessNamespace ${USER} ${PASS} ${PYTHON_NAMESPACE} | tail -1`
  echo "${CONTRACTID}" > ${DC_SHARED_VOLUME}/${PYTHON_NAMESPACE}_contractid

  i=$(expr ${i} + 1)

done

########################### import models ###########################

i=1
for IMPORT_MODELS_FROM_EXTERNAL_DC_HOST in $IMPORT_MODELS_FROM_EXTERNAL_DC_HOSTS; do

  IMPORT_MODELS_FROM_EXTERNAL_DC_PORT=$(echo "$IMPORT_MODELS_FROM_EXTERNAL_DC_PORTS" | cut -d\  -f${i})
  IMPORT_MODELS_FROM_EXTERNAL_DC_NAMESPACE=$(echo "$IMPORT_MODELS_FROM_EXTERNAL_DC_NAMESPACES" | cut -d\  -f${i})

  dataclaycmd ImportModelsFromExternalDataClay ${IMPORT_MODELS_FROM_EXTERNAL_DC_HOST} \
    ${IMPORT_MODELS_FROM_EXTERNAL_DC_PORT} ${IMPORT_MODELS_FROM_EXTERNAL_DC_NAMESPACE} ${ARGS}

  # Get contract ID for imported namespace
  CONTRACTID=`java -cp $DATACLAY_JAR es.bsc.dataclay.tool.AccessNamespace ${USER} ${PASS} ${IMPORT_MODELS_FROM_EXTERNAL_DC_NAMESPACE} | tail -1`
  echo "${CONTRACTID}" > ${DC_SHARED_VOLUME}/${IMPORT_MODELS_FROM_EXTERNAL_DC_NAMESPACE}_contractid

  i=$(expr ${i} + 1)
done

echo "READY" > /dataclay-initializer/state.txt

exit 0

#!/bin/sh
set -x
set -e

# Variables that are picked up from env
# - $DATACLAY_JAR
# - $USER
# - $PASS
# - $DATASET
# - $DC_SHARED_VOLUME
# - $LOGICMODULE_PORT_TCP
# - $LOGICMODULE_HOST
# - $JAVA_NAMESPACES
# - $PYTHON_NAMESPACES
# - $JAVA_MODELS_PATH
# - $PYTHON_MODELS_PATH
# - $IMPORT_MODELS_FROM_EXTERNAL_DC_HOSTS
# - $IMPORT_MODELS_FROM_EXTERNAL_DC_PORTS
# - $IMPORT_MODELS_FROM_EXTERNAL_DC_NAMESPACES

########################### create cfgfiles ###########################

printf "HOST=${LOGICMODULE_HOST}\nTCPPORT=${LOGICMODULE_PORT_TCP}" > ${DATACLAYCLIENTCONFIG}

######################################################

# Wait for dataclay to be alive (max retries 10 and 5 seconds per retry)
dataclaycmd WaitForDataClayToBeAlive 10 5

# Register account
dataclaycmd NewAccount ${USER} ${PASS}

# Register datacontract
dataclaycmd NewDataContract ${USER} ${PASS} ${DATASET} ${USER}

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
  dataclaycmd NewModel ${USER} ${PASS} ${JAVA_NAMESPACE} ${JAVA_MODEL}/target/classes java

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
  dataclaycmd NewModel ${USER} ${PASS} ${PYTHON_NAMESPACE} ${PYTHON_MODEL} python

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
    ${IMPORT_MODELS_FROM_EXTERNAL_DC_PORT} ${IMPORT_MODELS_FROM_EXTERNAL_DC_NAMESPACE}

  # Get contract ID for imported namespace
  CONTRACTID=`java -cp $DATACLAY_JAR es.bsc.dataclay.tool.AccessNamespace ${USER} ${PASS} ${IMPORT_MODELS_FROM_EXTERNAL_DC_NAMESPACE} | tail -1`
  echo "${CONTRACTID}" > ${DC_SHARED_VOLUME}/${IMPORT_MODELS_FROM_EXTERNAL_DC_NAMESPACE}_contractid

  i=$(expr ${i} + 1)
done

echo "READY" > /dataclay-initializer/state.txt

exit 0

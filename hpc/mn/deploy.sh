#!/bin/bash
#=== FUNCTION ================================================================
# NAME: get_container_version
# DESCRIPTION: Get container version
# PARAMETER 1: Execution environment version i.e. can be python py3.6 or jdk8
#===============================================================================
function get_container_version() {
  if [ $# -gt 0 ]; then
    EE_VERSION=$1
    DATACLAY_EE_VERSION="${EE_VERSION//./}"
    if [ "$DEV" = true ]; then
      DATACLAY_CONTAINER_VERSION="${DATACLAY_VERSION}.${DATACLAY_EE_VERSION}.dev"
    else
      DATACLAY_CONTAINER_VERSION="$DATACLAY_VERSION.${DATACLAY_EE_VERSION}"
    fi
  else
    if [ "$DEV" = true ]; then
      DATACLAY_CONTAINER_VERSION="${DATACLAY_VERSION}.dev"
    else
      DATACLAY_CONTAINER_VERSION="$DATACLAY_VERSION"
    fi
  fi
  echo ${DATACLAY_CONTAINER_VERSION}
}
#=== FUNCTION ================================================================
# NAME: deploy_logicmodule
# DESCRIPTION: Deploy logicmodule image
#=============================================================================
function deploy_logicmodule {
  IMAGE=logicmodule
  for JAVA_VERSION in "${SUPPORTED_JAVA_VERSIONS[@]}"; do
    EXECUTION_ENVIRONMENT=jdk${JAVA_VERSION}
    EXECUTION_ENVIRONMENT_TAG="$(get_container_version $EXECUTION_ENVIRONMENT)"
    singularity pull $DEPLOYSCRIPTDIR/${IMAGE}:${EXECUTION_ENVIRONMENT_TAG}.sif docker://bscdataclay/${IMAGE}:$EXECUTION_ENVIRONMENT_TAG
    scp $DEPLOYSCRIPTDIR/${IMAGE}:${EXECUTION_ENVIRONMENT_TAG}.sif dataclay@dt01.bsc.es:/gpfs/apps/MN4/DATACLAY/$DEFAULT_TAG/singularity/images/
  done
}
#=== FUNCTION ================================================================
# NAME: deploy_dsjava
# DESCRIPTION: Deploy dsjava image
#=============================================================================
function deploy_dsjava {
  IMAGE=dsjava
  for JAVA_VERSION in "${SUPPORTED_JAVA_VERSIONS[@]}"; do
    EXECUTION_ENVIRONMENT=jdk${JAVA_VERSION}
    EXECUTION_ENVIRONMENT_TAG="$(get_container_version $EXECUTION_ENVIRONMENT)"
    singularity pull $DEPLOYSCRIPTDIR/${IMAGE}:${EXECUTION_ENVIRONMENT_TAG}.sif docker://bscdataclay/${IMAGE}:$EXECUTION_ENVIRONMENT_TAG
    scp $DEPLOYSCRIPTDIR/${IMAGE}:${EXECUTION_ENVIRONMENT_TAG}.sif dataclay@dt01.bsc.es:/gpfs/apps/MN4/DATACLAY/$DEFAULT_TAG/singularity/images/
  done
}
#=== FUNCTION ================================================================
# NAME: deploy_dspython
# DESCRIPTION: Deploy dspython image
#=============================================================================
function deploy_dspython {
  IMAGE=dspython
  for PYTHON_VERSION in "${SUPPORTED_PYTHON_VERSIONS[@]}"; do
    EXECUTION_ENVIRONMENT=py$PYTHON_VERSION
    EXECUTION_ENVIRONMENT_TAG="$(get_container_version $EXECUTION_ENVIRONMENT)"
    singularity pull $DEPLOYSCRIPTDIR/${IMAGE}:${EXECUTION_ENVIRONMENT_TAG}.sif docker://bscdataclay/${IMAGE}:$EXECUTION_ENVIRONMENT_TAG
    scp $DEPLOYSCRIPTDIR/${IMAGE}:${EXECUTION_ENVIRONMENT_TAG}.sif dataclay@dt01.bsc.es:/gpfs/apps/MN4/DATACLAY/$DEFAULT_TAG/singularity/images/
  done
}
#=== FUNCTION ================================================================
# NAME: deploy_client
# DESCRIPTION: Deploy client image
#=============================================================================
function deploy_client {
  IMAGE=client
  singularity pull $DEPLOYSCRIPTDIR/${IMAGE}:${DEFAULT_TAG}.sif docker://bscdataclay/${IMAGE}:$DEFAULT_TAG
  scp $DEPLOYSCRIPTDIR/${IMAGE}:${DEFAULT_TAG}.sif dataclay@dt01.bsc.es:/gpfs/apps/MN4/DATACLAY/$DEFAULT_TAG/singularity/images/
}
#=== FUNCTION ================================================================
# NAME: deploy_orchestrator
# DESCRIPTION: Deploy orchestration scripts
#=============================================================================
function deploy_orchestrator {
  echo "[marenostrum-deploy] Deploying $DEFAULT_TAG to MN..."
  # Prepare module definition
  sed "s/SET_VERSION_HERE/${DEFAULT_TAG}/g" $DEPLOYSCRIPTDIR/module.lua > /tmp/${DEFAULT_TAG}.lua
  # Deploy singularity and orchestration scripts to Marenostrum
  DEPLOY_CMD="rm -rf /apps/DATACLAY/$DEFAULT_TAG/ &&\
   mkdir -p /apps/DATACLAY/$DEFAULT_TAG/singularity/images/ &&\
   mkdir -p /apps/DATACLAY/$DEFAULT_TAG/javaclay &&\
   mkdir -p /apps/DATACLAY/$DEFAULT_TAG/pyclay"

  echo "[marenostrum-deploy] Cleaning and preparing folders in MN..."
  ssh dataclay@mn2.bsc.es "$DEPLOY_CMD"

  # Send orchestration script and images
  echo "[marenostrum-deploy] Deploying dataclay orchestrator and singularity images..."
  rsync -av -e ssh $PACKAGING_DIR/orchestration/* dataclay@dt01.bsc.es:/gpfs/apps/MN4/DATACLAY/$DEFAULT_TAG

  # Send javaclay and pyclay
  echo "[marenostrum-deploy] Deploying javaclay..."
  pushd $PACKAGING_DIR/docker/logicmodule/javaclay
  mvn package -DskipTests=true
  scp target/*-jar-with-dependencies.jar dataclay@dt01.bsc.es:/gpfs/apps/MN4/DATACLAY/$DEFAULT_TAG/javaclay/dataclay.jar
  popd
  echo "[marenostrum-deploy] Deploying pyclay..."
  rsync -av -e ssh --progress $PACKAGING_DIR/docker/dspython/pyclay/* dataclay@dt01.bsc.es:/gpfs/apps/MN4/DATACLAY/$DEFAULT_TAG/pyclay/

  # Changing permissions in pyclay folder
  ssh dataclay@mn2.bsc.es "chmod -R g-w /apps/DATACLAY/$DEFAULT_TAG/pyclay/"

  # Module definition
  echo "[marenostrum-deploy] Deploying dataclay module..."
  scp /tmp/${DEFAULT_TAG}.lua dataclay@dt01.bsc.es:/gpfs/apps/MN4/DATACLAY/modules/
  MODULE_LINK="develop"
  if [ "$DEV" = false ] ; then
    MODULE_LINK="latest"
  fi
  ssh dataclay@mn2.bsc.es "rm /apps/DATACLAY/modules/${MODULE_LINK}.lua && ln -s /apps/DATACLAY/modules/${DEFAULT_TAG}.lua /apps/DATACLAY/modules/${MODULE_LINK}.lua"


}

DEPLOYSCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $DEPLOYSCRIPTDIR/common.sh
PACKAGING_DIR=$DEPLOYSCRIPTDIR/../..
ORCHESTRATION_DIR=$PACKAGING_DIR/orchestration
DEFAULT_TAG=$(cat $ORCHESTRATION_DIR/VERSION.txt)
IMAGES=(logicmodule dsjava dspython client)
CONFIG_FILE=$PACKAGING_DIR/docker/common/normal.config
while test $# -gt 0; do
  case "$1" in
  --images)
    shift
    IFS=' ' read -r -a IMAGES <<< "$1"
    ;;
  --config-file)
    shift
    CONFIG_FILE=$1
    printWarn "Configuration file used in all images: $CONFIG_FILE"
    ;;
  *)
    echo "Bad option $1"
    exit 1
    ;;
  esac
  shift
done
source $CONFIG_FILE

SECONDS=0
deploy_orchestrator
for IMAGE in "${IMAGES[@]}"; do
  echo "[marenostrum-deploy] Deploying $IMAGE image to MN..."
  deploy_$IMAGE
done

duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
echo "MN deployment successfully finished!"

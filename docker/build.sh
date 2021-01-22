#!/bin/bash -e
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
echo " Welcome to dataClay build script!"
SECONDS=0
################################## BUILD #############################################
source $SCRIPTDIR/../common/PLATFORMS.txt
ARGS=""
while test $# -gt 0
do
  param="$1"
  ARGS+="$param "
  case $param in
        --slim)
          source $SCRIPTDIR/../common/SLIM_PLATFORMS.txt
          ;;
        --alpine)
          source $SCRIPTDIR/../common/ALPINE_PLATFORMS.txt
          ;;
        --build-platform)
          $SCRIPTDIR/../common/prepare_docker_builder.sh
          ;;
        --plaforms-file)
          shift
          PLATFORMS_FILE=$1
          source $PLATFORMS_FILE
          ARGS+="$1 "
          ;;
        *)
          ;;
  esac
  shift
done


# PACKAGE
pushd $SCRIPTDIR/logicmodule
docker build -f packager.Dockerfile -t bscdataclay/javaclay .
popd

for JAVA_VERSION in ${SUPPORTED_JAVA_VERSIONS[@]}; do
  $SCRIPTDIR/logicmodule/build.sh $ARGS --ee jdk${JAVA_VERSION} --share-builder
  $SCRIPTDIR/dsjava/build.sh $ARGS --ee jdk${JAVA_VERSION} --share-builder
done
for PYTHON_VERSION in ${SUPPORTED_PYTHON_VERSIONS[@]}; do
  $SCRIPTDIR/dspython/build.sh $ARGS --ee py${PYTHON_VERSION} --share-builder

done
$SCRIPTDIR/client/build.sh $ARGS --share-builder
duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
echo "[dataClay build] FINISHED! "

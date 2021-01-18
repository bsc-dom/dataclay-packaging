#!/bin/bash -e
#===================================================================================
#
# FILE: deploy.sh
#
# USAGE: deploy.sh [--dev] 
#
# DESCRIPTION: Deploy dataClay dockers into DockerHub
#
# OPTIONS: ---
# REQUIREMENTS: ---
# BUGS: ---
# NOTES: ---
# AUTHOR: dgasull@bsc.es
# COMPANY: Barcelona Supercomputing Center (BSC)
# VERSION: 1.0
#===================================================================================
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
echo "'"'
      _       _         _____ _             
     | |     | |       / ____| |            
   __| | __ _| |_ __ _| |    | | __ _ _   _ 
  / _` |/ _` | __/ _` | |    | |/ _` | | | |
 | (_| | (_| | || (_| | |____| | (_| | |_| |  deploy script
  \__,_|\__,_|\__\__,_|\_____|_|\__,_|\__, |
                                       __/ |
                                      |___/ 
'"'"
echo " Welcome to dataClay deploy script!"
SECONDS=0
if [[ "$*" == *--slim* ]]; then
  source $SCRIPTDIR/../common/SLIM_PLATFORMS.txt
elif [[ "$*" == *--alpine* ]]; then
  source $SCRIPTDIR/../common/ALPINE_PLATFORMS.txt
else
  source $SCRIPTDIR/../common/PLATFORMS.txt
fi

source $SCRIPTDIR/../common/prepare_docker_builder.sh
# PACKAGE
pushd $SCRIPTDIR/logicmodule
docker build -f packager.Dockerfile -t bscdataclay/javaclay .
popd

for JAVA_VERSION in ${SUPPORTED_JAVA_VERSIONS[@]}; do
  $SCRIPTDIR/logicmodule/deploy.sh "$@" --ee jdk${JAVA_VERSION} --share-builder
  $SCRIPTDIR/dsjava/deploy.sh "$@" --ee jdk${JAVA_VERSION} --share-builder
done
for PYTHON_VERSION in ${SUPPORTED_PYTHON_VERSIONS[@]}; do
  $SCRIPTDIR/dspython/deploy.sh "$@" --ee py${PYTHON_VERSION} --share-builder
done

$SCRIPTDIR/client/deploy.sh "$@" --share-builder

duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
echo "[dataClay deploy] FINISHED! "

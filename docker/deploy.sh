#!/bin/bash
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
set -e
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

# CREATE DATACLAY JAR
pushd $SCRIPTDIR/logicmodule/javaclay
echo "Packaging dataclay.jar"
mvn package -q -DskipTests=true >/dev/null
echo "dataclay.jar created!"
popd

$SCRIPTDIR/base/deploy.sh "$@"
for JAVA_VERSION in ${SUPPORTED_JAVA_VERSIONS[@]}; do
  $SCRIPTDIR/logicmodule/deploy.sh "$@" --ee jdk${JAVA_VERSION} --do-not-package
  $SCRIPTDIR/dsjava/deploy.sh "$@" --ee jdk${JAVA_VERSION} --do-not-package
done
for PYTHON_VERSION in ${SUPPORTED_PYTHON_VERSIONS[@]}; do
  $SCRIPTDIR/dspython/deploy.sh "$@" --ee py${PYTHON_VERSION}
done
$SCRIPTDIR/client/deploy.sh "$@"
duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
echo "[dataClay deploy] FINISHED! "

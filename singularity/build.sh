#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
################################## MAIN #############################################
set -e
echo "'"'
      _       _         _____ _             
     | |     | |       / ____| |            
   __| | __ _| |_ __ _| |    | | __ _ _   _ 
  / _` |/ _` | __/ _` | |    | |/ _` | | | |
 | (_| | (_| | || (_| | |____| | (_| | |_| |  SINGULARITY build script
  \__,_|\__,_|\__\__,_|\_____|_|\__,_|\__, |
                                       __/ |
                                      |___/ 
'"'"
echo " Welcome to dataClay build script!"
source $SCRIPTDIR/../common/PLATFORMS.txt

for JAVA_VERSION in ${SUPPORTED_JAVA_VERSIONS[@]}; do
	$SCRIPTDIR/logicmodule/build.sh "$@" --ee jdk${JAVA_VERSION}
	$SCRIPTDIR/dsjava/build.sh "$@" --ee jdk${JAVA_VERSION}
done
for PYTHON_VERSION in ${SUPPORTED_PYTHON_VERSIONS[@]}; do
	$SCRIPTDIR/dspython/build.sh "$@" --ee py${PYTHON_VERSION}
done
$SCRIPTDIR/client/build.sh "$@"

# Check docker images 
echo "Generated images:"
ls -la ../orchestration/singularity/images | grep "logicmodule"
ls -la ../orchestration/singularity/images | grep "dsjava"
ls -la ../orchestration/singularity/images | grep "dspython"
ls -la ../orchestration/singularity/images | grep "client"

echo "[dataClay singularity build] FINISHED! "

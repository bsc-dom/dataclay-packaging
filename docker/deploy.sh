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
source $SCRIPTDIR/../common/PLATFORMS.txt

$SCRIPTDIR/base/deploy.sh "$@"
for JAVA_VERSION in ${SUPPORTED_JAVA_VERSIONS[@]}; do
	$SCRIPTDIR/logicmodule/deploy.sh "$@" --ee jdk${JAVA_VERSION}
	$SCRIPTDIR/dsjava/deploy.sh "$@" --ee jdk${JAVA_VERSION}
done
for PYTHON_VERSION in ${SUPPORTED_PYTHON_VERSIONS[@]}; do
	$SCRIPTDIR/dspython/deploy.sh "$@" --ee py${PYTHON_VERSION}
done
$SCRIPTDIR/client/deploy.sh "$@"

echo "[dataClay deploy] FINISHED! "

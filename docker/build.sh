#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
set -e
echo "'"'
      _       _         _____ _             
     | |     | |       / ____| |            
   __| | __ _| |_ __ _| |    | | __ _ _   _ 
  / _` |/ _` | __/ _` | |    | |/ _` | | | |
 | (_| | (_| | || (_| | |____| | (_| | |_| |  build script
  \__,_|\__,_|\__\__,_|\_____|_|\__,_|\__, |
                                       __/ |
                                      |___/ 
'"'"
echo " Welcome to dataClay build script!"
SECONDS=0
################################## BUILD #############################################
source $SCRIPTDIR/../common/PLATFORMS.txt
if [[ "$*" == *--slim* ]] || [[ "$*" == *--alpine* ]]; then
  export PACKAGE_PROFILE="-Pslim"
fi

# CREATE DATACLAY JAR
pushd $SCRIPTDIR/logicmodule/javaclay
  echo "Packaging dataclay.jar using profile $PACKAGE_PROFILE"
  mvn clean package $PACKAGE_PROFILE -DskipTests=true
  echo "dataclay.jar created!"
popd


$SCRIPTDIR/base/build.sh "$@"
for JAVA_VERSION in ${SUPPORTED_JAVA_VERSIONS[@]}; do
  $SCRIPTDIR/logicmodule/build.sh "$@" --ee jdk${JAVA_VERSION} --do-not-package #already packaged
  $SCRIPTDIR/dsjava/build.sh "$@" --ee jdk${JAVA_VERSION} --do-not-package
done
for PYTHON_VERSION in ${SUPPORTED_PYTHON_VERSIONS[@]}; do
  $SCRIPTDIR/dspython/build.sh "$@" --ee py${PYTHON_VERSION}

done
$SCRIPTDIR/client/build.sh "$@"


# Check docker images 
echo "Generated images:"
docker images | grep "$REPOSITORY/base" | grep "${TAG_SUFFIX}"
docker images | grep "$REPOSITORY/logicmodule"  | grep "${TAG_SUFFIX}"
docker images | grep "$REPOSITORY/dsjava"  | grep "${TAG_SUFFIX}"
docker images | grep "$REPOSITORY/dspython"  | grep "${TAG_SUFFIX}"
docker images | grep "$REPOSITORY/client"  | grep "${TAG_SUFFIX}"
duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
echo "[dataClay build] FINISHED! "

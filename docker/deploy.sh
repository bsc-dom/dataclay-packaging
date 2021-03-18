#!/bin/bash -e
#===================================================================================
#
# FILE: release.sh
#
# USAGE: release.sh [--dev]
#
# DESCRIPTION: Release dataClay dockers into DockerHub
#
# OPTIONS: ---
# REQUIREMENTS: ---
# BUGS: ---
# NOTES: ---
# AUTHOR: dgasull@bsc.es
# COMPANY: Barcelona Supercomputing Center (BSC)
# VERSION: 1.0
#===================================================================================
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
#==============================================================================
grn=$'\e[1;32m'
blu=$'\e[1;34m'
red=$'\e[1;91m'
yellow=$'\e[1;33m'
end=$'\e[0m'
function printMsg() { echo "${blu}$1${end}"; }
function printInfo() { echo "${yellow}$1${end}"; }
function printWarn() { echo "${yellow}WARNING: $1${end}"; }
function printError() { echo "${red}======== $1 ========${end}"; }
#=== FUNCTION ================================================================
# NAME: deploy
# DESCRIPTION: Deploy to DockerHub and retry if connection fails
#=============================================================================
function tag {
  COMMAND=""
  while [[ $# -gt 0 ]]; do
    param="$1"
    case $param in
    *) # unknown option
      COMMAND+="$1 "
      shift # past argument
      ;;
    esac
  done
  printMsg "${COMMAND}"
  eval "${COMMAND}"
}
#=== FUNCTION ================================================================
# NAME: deploy
# DESCRIPTION: Deploy to DockerHub and retry if connection fails
#=============================================================================
function deploy {
  SECONDS=0
  COMMAND=""
  while [[ $# -gt 0 ]]; do
    param="$1"
    case $param in
    -t)
      IMAGE_NAME="$2"
      COMMAND+="$1 $2 "
      shift # past argument
      shift # past value
      ;;
    *) # unknown option
      COMMAND+="$1 "
      shift # past argument
      ;;
    esac
  done
  export n=0
  until [ "$n" -ge 5 ]; do # Retry maximum 5 times
    printMsg "************* Pushing/building image $IMAGE_NAME (retry $n) *************"
    printMsg "$COMMAND"
    eval "$COMMAND" && break
    n=$((n + 1))
    sleep 15
  done
  if [ "$n" -eq 5 ]; then
    printError "ERROR: $IMAGE_NAME could not be pushed"
    return 1
  fi

  printMsg "************* $IMAGE_NAME IMAGE done! (in $n retries) *************"
  echo "$(($SECONDS / 60)) minutes and $(($SECONDS % 60)) seconds elapsed."
}
#=== FUNCTION ================================================================
# NAME: prepare_docker_buildx
# DESCRIPTION: Prepare docker buildx and check
#=============================================================================
function prepare_docker_buildx {
  printf "Checking if docker version >= $REQUIRED_DOCKER_VERSION..."
  version=$(docker version --format '{{.Server.Version}}')
  if [[ "$version" < "$REQUIRED_DOCKER_VERSION" ]]; then
    echo "ERROR: Docker version is less than $REQUIRED_DOCKER_VERSION"
    exit 1
  fi
  printf "OK\n"
  # Check if already exists
  echo "Checking builder dataclay-builderx"
  RESULT=$(docker buildx ls)
  if [[ $RESULT == *"dataclay-builderx"* ]]; then
    echo "Using already existing builder dataclay-builderx"
    docker buildx use dataclay-builderx
  else
    echo "Creating builder $BUILDERX_NAME"
    # prepare architectures
    docker run --rm --privileged docker/binfmt:a7996909642ee92942dcd6cff44b9b95f08dad64
    #docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
    docker run --rm -t arm64v8/ubuntu uname -m
    docker buildx create --driver-opt network=host --name dataclay-builderx
    docker buildx use dataclay-builderx
    echo "Checking buildx with available platforms to simulate..."
    docker buildx inspect --bootstrap

    if [ -f "/usr/local/share/ca-certificates/dom-ci.bsc.es.crt" ]; then
      echo "Copying certificate /usr/local/share/ca-certificates/dom-ci.bsc.es.crt to docker buildx"
      BUILDER=$(docker ps | grep buildkitd | cut -f1 -d' ')
      docker cp /usr/local/share/ca-certificates/dom-ci.bsc.es.crt $BUILDER:/usr/local/share/ca-certificates/
      docker exec $BUILDER update-ca-certificates
      docker restart $BUILDER
    fi

    BUILDER_PLATFORMS=$(docker buildx inspect --bootstrap | grep Platforms | awk -F":" '{print $2}')
    IFS=',' read -ra BUILDER_PLATFORMS_ARRAY <<<"$BUILDER_PLATFORMS"
    IFS=',' read -ra SUPPORTED_PLATFORMS_ARRAY <<<"$PLATFORMS"
    echo "Builder created with platforms:"
    for element in "${BUILDER_PLATFORMS_ARRAY[@]}"; do
      printf $element
    done
    printf "\n"
    #Print the split string
    for i in "${SUPPORTED_PLATFORMS_ARRAY[@]}"; do
      FOUND=false
      SUP_PLATFORM=$(echo $i | sed 's/ *$//g') #remove spaces
      printf "Checking if platform $i can be simulated by buildx..."
      for j in "${BUILDER_PLATFORMS_ARRAY[@]}"; do
        B_PLATFORM=$(echo $j | sed 's/ *$//g') #remove spaces
        if [ "$SUP_PLATFORM" == "$B_PLATFORM" ]; then
          FOUND=true
          break
        fi
      done
      if [ "$FOUND" = false ]; then
        echo "ERROR: missing support for $i in buildx builder."
        echo " Check https://github.com/multiarch/qemu-user-static for more information on how to simulate architectures"
        return 1
      fi
      printf "OK\n"

    done
  fi

}
#=== FUNCTION ================================================================
# NAME: deploy_base
# DESCRIPTION: Deploy base image
#=============================================================================
function deploy_base {
  IMAGE=base
  BASE_TAG="${DEFAULT_TAG}"
  pushd $SCRIPTDIR/$IMAGE
  deploy docker $DOCKER_BUILDX_COMMAND build --rm $DOCKERFILE -t ${REGISTRY}/$IMAGE:$BASE_TAG \
         --build-arg VCS_REF=$VCS_REF \
         --build-arg BUILD_DATE=$BUILD_DATE \
				 $PLATFORMS_COMMAND $DOCKER_PROGRESS \
				 $DOCKER_COMMAND .
  popd
  if [ "$DEV" = false ] ; then
    tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/$IMAGE:$DATACLAY_VERSION_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/$IMAGE
    [[ ! -z "$TAG_SUFFIX" ]] && tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/$IMAGE:$DEFAULT_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/$IMAGE:"${TAG_SUFFIX//-}" # alpine or slim tags
  else
    tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/$IMAGE:$DEFAULT_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/$IMAGE:develop${TAG_SUFFIX}
    if [ "$ADD_DATE_TAG" = true ] ; then
      tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/$IMAGE:$DEFAULT_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/$IMAGE:dev${CUR_DATE_TAG}${TAG_SUFFIX}
    fi
  fi
}
#=== FUNCTION ================================================================
# NAME: deploy_python_requirements
# DESCRIPTION: Deploy python requirements images
#=============================================================================
function deploy_python_requirements {
  for PYTHON_VERSION in "${SUPPORTED_PYTHON_VERSIONS[@]}"; do
    EXECUTION_ENVIRONMENT=py$PYTHON_VERSION
    IMAGE=dspython
    EXECUTION_ENVIRONMENT_TAG="$(get_container_version $EXECUTION_ENVIRONMENT)${TAG_SUFFIX}"
    REQUIREMENTS_TAG=${EXECUTION_ENVIRONMENT_TAG}-requirements
    pushd $SCRIPTDIR/$IMAGE
    deploy docker $DOCKER_BUILDX_COMMAND build --rm $DOCKERFILE -t ${REGISTRY}/$IMAGE:$REQUIREMENTS_TAG \
        --build-arg DATACLAY_PYVER=$PYTHON_VERSION \
        --build-arg PYTHON_PIP_VERSION=$PYTHON_PIP_VERSION \
           $PLATFORMS_COMMAND $DOCKER_PROGRESS \
           $DOCKER_COMMAND .
    popd
    if [ "$DEV" = false ] ; then
      tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/$IMAGE:$DATACLAY_VERSION_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/$IMAGE
      [[ ! -z "$TAG_SUFFIX" ]] && tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/$IMAGE:$DEFAULT_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/$IMAGE:"${TAG_SUFFIX//-}" # alpine or slim tags
    else
      tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/$IMAGE:$DEFAULT_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/$IMAGE:develop${TAG_SUFFIX}
      if [ "$ADD_DATE_TAG" = true ] ; then
        tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/$IMAGE:$DEFAULT_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/$IMAGE:dev${CUR_DATE_TAG}${TAG_SUFFIX}
      fi
    fi
  done
}

#=== FUNCTION ================================================================
# NAME: deploy_logicmodule
# DESCRIPTION: Deploy logicmodule image
#=============================================================================
function deploy_logicmodule {
  for JAVA_VERSION in "${SUPPORTED_JAVA_VERSIONS[@]}"; do
    EXECUTION_ENVIRONMENT=jdk${JAVA_VERSION}
    IMAGE=logicmodule
    EXECUTION_ENVIRONMENT_TAG="$(get_container_version $EXECUTION_ENVIRONMENT)${TAG_SUFFIX}"
    JAR_VERSION=$(grep version $SCRIPTDIR/logicmodule/javaclay/pom.xml | grep -v -e '<?xml|~' | head -n 1 | sed 's/[[:space:]]//g' | sed -E 's/<.{0,1}version>//g' | awk '{print $1}')

    pushd $SCRIPTDIR/$IMAGE
    JAVACLAY_CONTAINER=$(docker create --rm bscdataclay/javaclay)
    docker cp $JAVACLAY_CONTAINER:/javaclay/target/dataclay-${JAR_VERSION}-shaded.jar ./dataclay.jar
    docker rm $JAVACLAY_CONTAINER

    deploy docker $DOCKER_BUILDX_COMMAND build --rm $DOCKERFILE -t ${REGISTRY}/logicmodule:$EXECUTION_ENVIRONMENT_TAG \
      --build-arg VCS_REF=$VCS_REF \
      --build-arg BUILD_DATE=$BUILD_DATE \
      --build-arg VERSION=$EXECUTION_ENVIRONMENT_TAG \
      --build-arg JDK=$JAVA_VERSION \
      --build-arg BASE_VERSION=$BASE_VERSION_TAG \
      $PLATFORMS_COMMAND $DOCKER_PROGRESS \
      $DOCKER_COMMAND .
    popd
    if [ $EXECUTION_ENVIRONMENT_TAG == $DEFAULT_JDK_TAG ]; then
      ## Tag default versions 2.6.dev is 2.6.jdk11.dev // 2.6 is 2.6.dev
      tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/logicmodule:$DEFAULT_JDK_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/logicmodule:$DEFAULT_TAG
      ##### TAG LATEST #####
      if [ "$DEV" = false ] ; then
        tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/logicmodule:$DATACLAY_VERSION_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/logicmodule
        [[ ! -z "$TAG_SUFFIX" ]] && tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/logicmodule:$DEFAULT_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/logicmodule:"${TAG_SUFFIX//-}" # alpine or slim tags
      else
        tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/logicmodule:$DEFAULT_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/logicmodule:develop${TAG_SUFFIX}
        if [ "$ADD_DATE_TAG" = true ] ; then
          tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/logicmodule:$DEFAULT_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/logicmodule:dev${CUR_DATE_TAG}${TAG_SUFFIX}
        fi
      fi
    fi
    if [ "$DEV" = true ] ; then
      tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/logicmodule:$EXECUTION_ENVIRONMENT_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/logicmodule:develop.jdk${JAVA_VERSION}${TAG_SUFFIX}
      if [ "$ADD_DATE_TAG" = true ] ; then
        tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/logicmodule:$EXECUTION_ENVIRONMENT_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/logicmodule:dev${CUR_DATE_TAG}.jdk${JAVA_VERSION}${TAG_SUFFIX}
      fi
    fi
  done
}

#=== FUNCTION ================================================================
# NAME: deploy_dsjava
# DESCRIPTION: Deploy dsjava image
#=============================================================================
function deploy_dsjava {
  for JAVA_VERSION in "${SUPPORTED_JAVA_VERSIONS[@]}"; do
    EXECUTION_ENVIRONMENT=jdk${JAVA_VERSION}
    IMAGE=dsjava
    EXECUTION_ENVIRONMENT_TAG="$(get_container_version $EXECUTION_ENVIRONMENT)${TAG_SUFFIX}"

    pushd $SCRIPTDIR/$IMAGE

    deploy docker $DOCKER_BUILDX_COMMAND build --rm $DOCKERFILE -t ${REGISTRY}/dsjava:$EXECUTION_ENVIRONMENT_TAG \
             --build-arg VCS_REF=$VCS_REF \
             --build-arg BUILD_DATE=$BUILD_DATE \
             --build-arg VERSION=$EXECUTION_ENVIRONMENT_TAG \
             --build-arg LOGICMODULE_VERSION=$EXECUTION_ENVIRONMENT_TAG \
             $PLATFORMS_COMMAND $DOCKER_PROGRESS \
             $DOCKER_COMMAND .
    popd
    if [ $EXECUTION_ENVIRONMENT_TAG == $DEFAULT_JDK_TAG ]; then
      ## Tag default versions
      tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/dsjava:$DEFAULT_JDK_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/dsjava:$DEFAULT_TAG

      ##### TAG LATEST #####
      if [ "$DEV" = false ] ; then
        tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/dsjava:$DATACLAY_VERSION_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/dsjava
        [[ ! -z "$TAG_SUFFIX" ]] && tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/dsjava:$DEFAULT_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/dsjava:"${TAG_SUFFIX//-}" # alpine or slim tags
      else
        tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/dsjava:$DEFAULT_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/dsjava:develop${TAG_SUFFIX}
        if [ "$ADD_DATE_TAG" = true ] ; then
          tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/dsjava:$DEFAULT_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/dsjava:dev${CUR_DATE_TAG}${TAG_SUFFIX}
        fi
      fi
    fi
    if [ "$DEV" = true ] ; then
      tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/dsjava:$EXECUTION_ENVIRONMENT_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/dsjava:develop.jdk${JAVA_VERSION}${TAG_SUFFIX}
      if [ "$ADD_DATE_TAG" = true ] ; then
        tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/dsjava:$EXECUTION_ENVIRONMENT_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/dsjava:dev${CUR_DATE_TAG}.jdk${JAVA_VERSION}${TAG_SUFFIX}
      fi
    fi
  done
}


#=== FUNCTION ================================================================
# NAME: deploy_dspython
# DESCRIPTION: Deploy dspython image
#=============================================================================
function deploy_dspython {
  for PYTHON_VERSION in "${SUPPORTED_PYTHON_VERSIONS[@]}"; do
    EXECUTION_ENVIRONMENT=py$PYTHON_VERSION
    IMAGE=dspython
    EXECUTION_ENVIRONMENT_TAG="$(get_container_version $EXECUTION_ENVIRONMENT)${TAG_SUFFIX}"
    REQUIREMENTS_TAG=${EXECUTION_ENVIRONMENT_TAG}-requirements
    if [[ "$TAG_SUFFIX" == "-arm32" ]]; then
      REQUIREMENTS_TAG=$(get_container_version $EXECUTION_ENVIRONMENT)-alpine-requirements
    fi
    PYTHON_VERSION=${EXECUTION_ENVIRONMENT#"py"}
    # Get python version without subversion to install it in some packages
    PYTHON_PIP_VERSION=$(echo $PYTHON_VERSION | awk -F '.' '{print $1}')
    pushd $SCRIPTDIR/$IMAGE

    deploy docker $DOCKER_BUILDX_COMMAND build --rm $DOCKERFILE -t ${REGISTRY}/dspython:$EXECUTION_ENVIRONMENT_TAG \
        --build-arg VCS_REF=$VCS_REF \
        --build-arg BUILD_DATE=$BUILD_DATE \
        --build-arg VERSION=$EXECUTION_ENVIRONMENT_TAG \
        --build-arg BASE_VERSION=$BASE_VERSION_TAG \
        --build-arg REQUIREMENTS_TAG=${REQUIREMENTS_TAG} \
        --build-arg DATACLAY_PYVER=$PYTHON_VERSION \
        --build-arg PYTHON_PIP_VERSION=$PYTHON_PIP_VERSION \
        $PLATFORMS_COMMAND $DOCKER_PROGRESS \
        $DOCKER_COMMAND .

    popd
    if [ $EXECUTION_ENVIRONMENT_TAG == $DEFAULT_PY_TAG ]; then
      ## Tag default versions
      tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/dspython:$DEFAULT_PY_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/dspython:$DEFAULT_TAG
      ##### TAG LATEST #####
      if [ "$DEV" = false ] ; then
        tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/dspython:$DATACLAY_VERSION_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/dspython
        [[ ! -z "$TAG_SUFFIX" ]] && tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/dspython:$DEFAULT_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/dspython:"${TAG_SUFFIX//-}"# alpine or slim tags
      else
        tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/dspython:$DEFAULT_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/dspython:develop${TAG_SUFFIX}
        if [ "$ADD_DATE_TAG" = true ] ; then
          tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/dspython:$DEFAULT_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/dspython:dev${CUR_DATE_TAG}${TAG_SUFFIX}
        fi
      fi
    fi
    if [ "$DEV" = true ] ; then
      DATACLAY_PYTHON_VERSION="${PYTHON_VERSION//./}"
      tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/dspython:$EXECUTION_ENVIRONMENT_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/dspython:develop.py${DATACLAY_PYTHON_VERSION}${TAG_SUFFIX}
      if [ "$ADD_DATE_TAG" = true ] ; then
        tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/dspython:$EXECUTION_ENVIRONMENT_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/dspython:dev${CUR_DATE_TAG}.py${DATACLAY_PYTHON_VERSION}${TAG_SUFFIX}
      fi
    fi
  done
}
#=== FUNCTION ================================================================
# NAME: deploy_client
# DESCRIPTION: Deploy client image
#=============================================================================
function deploy_client {
  IMAGE=client
  CLIENT_TAG="${DEFAULT_TAG}"
  DEFAULT_JDK_CLIENT_TAG="$(get_container_version jdk$CLIENT_JAVA)${TAG_SUFFIX}"
  DEFAULT_PY_CLIENT_TAG="$(get_container_version py$CLIENT_PYTHON)${TAG_SUFFIX}"

  pushd $SCRIPTDIR/$IMAGE
  deploy docker $DOCKER_BUILDX_COMMAND build --rm $DOCKERFILE -t ${REGISTRY}/client:$CLIENT_TAG \
         --build-arg VCS_REF=$VCS_REF \
         --build-arg BUILD_DATE=$BUILD_DATE \
         --build-arg VERSION=$CLIENT_TAG \
				 --build-arg DATACLAY_DSPYTHON_DOCKER_TAG=$DEFAULT_PY_CLIENT_TAG \
				 --build-arg DATACLAY_LOGICMODULE_DOCKER_TAG=$DEFAULT_JDK_CLIENT_TAG \
				 --build-arg DATACLAY_PYVER=$CLIENT_PYTHON \
			   --build-arg JDK=$CLIENT_JAVA \
				 $PLATFORMS_COMMAND $DOCKER_PROGRESS \
				 $DOCKER_COMMAND .
  popd
  if [ "$DEV" = false ] ; then
    tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/client:$DATACLAY_VERSION_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/client
    [[ ! -z "$TAG_SUFFIX" ]] && tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/client:$DEFAULT_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/client:"${TAG_SUFFIX//-}" # alpine or slim tags
  else
    tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/client:$DEFAULT_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/client:develop${TAG_SUFFIX}
    if [ "$ADD_DATE_TAG" = true ] ; then
      tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/client:$DEFAULT_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/client:dev${CUR_DATE_TAG}${TAG_SUFFIX}
    fi
  fi
}
#=== FUNCTION ================================================================
# NAME: deploy_initializer
# DESCRIPTION: Deploy initializer image
#=============================================================================
function deploy_initializer {
  IMAGE=initializer
  pushd $SCRIPTDIR/$IMAGE
  deploy docker $DOCKER_BUILDX_COMMAND build --rm $DOCKERFILE -t ${REGISTRY}/initializer:$DEFAULT_TAG \
           --build-arg VCS_REF=$VCS_REF \
           --build-arg BUILD_DATE=$BUILD_DATE \
           --build-arg CLIENT_TAG=$CLIENT_TAG \
           $PLATFORMS_COMMAND $DOCKER_PROGRESS \
           $DOCKER_COMMAND .
  popd
  if [ "$DEV" = false ] ; then
    tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/initializer:$DATACLAY_VERSION_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/initializer
    [[ ! -z "$TAG_SUFFIX" ]] && tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/initializer:$DEFAULT_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/initializer:"${TAG_SUFFIX//-}" # alpine or slim tags
  else
    tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/initializer:$DEFAULT_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/initializer:develop${TAG_SUFFIX}
    if [ "$ADD_DATE_TAG" = true ] ; then
      tag docker $DOCKER_TAG_COMMAND ${REGISTRY}/initializer:$DEFAULT_TAG $DOCKER_TAG_SUFFIX ${REGISTRY}/initializer:dev${CUR_DATE_TAG}${TAG_SUFFIX}
    fi
  fi
}

################################## OPTIONS ####################################
set -e
SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
echo " Welcome to dataClay release script!"

DEV=false
LOCAL=false
DONOTPROMPT=false
DOCKERFILE=""
TAG_SUFFIX=""
BRANCH_TO_CHECK="master"
DOCKER_PROGRESS=""
DOCKER_COMMAND="--push"
DOCKER_BUILDX_COMMAND="buildx"
DOCKER_TAG_COMMAND="buildx imagetools create"
DOCKER_TAG_SUFFIX="--tag"
ADD_DATE_TAG=false
VCS_REF=$(git rev-parse --short HEAD)
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
CUR_DATE_TAG=$(date -u +"%Y%m%d")
IMAGE_TYPES=(alpine slim arm32 normal)
IMAGES=(logicmodule dsjava dspython client initializer)
REGISTRY=bscdataclay
while test $# -gt 0; do
  case "$1" in
  --build)
    # local build
    DEV=true
    LOCAL=true
    VCS_REF="abc1234"
    BUILD_DATE="0000-00-00"
    DOCKER_BUILDX_COMMAND=""
    DOCKER_COMMAND=""
    DOCKER_TAG_COMMAND="tag"
    DOCKER_TAG_SUFFIX=""
    printWarn "Build in local docker"
    ;;
  --dev-release)
    DEV=true
    BRANCH_TO_CHECK="develop"
    ADD_DATE_TAG=true
    printWarn "Deploying development version to DockerHub"
    ;;
  --dev)
    DEV=true
    BRANCH_TO_CHECK="develop"
    VCS_REF="abc1234"
    BUILD_DATE="0000-00-00"
    REGISTRY=dom-ci.bsc.es/bscdataclay
    printWarn "Deploying to dom-ci.bsc.es registry"
    ;;
  --image-types)
    shift
    IFS=' ' read -r -a IMAGE_TYPES <<< "$1"
    ;;
  --images)
    shift
    IFS=' ' read -r -a IMAGES <<< "$1"
    ;;
  --config-file)
    shift
    CONFIG_FILE=$1
    printWarn "Configuration file used in all images: $CONFIG_FILE"
    ;;
  -y)
    DONOTPROMPT=true
    ;;
  --add-date-tag)
    ADD_DATE_TAG=true
    ;;
  --plain)
    DOCKER_PROGRESS="--progress plain"
    ;;
  *)
    echo "Bad option $1"
    exit 1
    ;;
  esac
  shift
done
###############################################################################

#GIT_BRANCH=$(git for-each-ref --format='%(objectname) %(refname:short)' refs/heads | awk "/^$(git rev-parse HEAD)/ {print \$2}")
#if [[ "$GIT_BRANCH" != "$BRANCH_TO_CHECK" ]]; then
#  printError "Branch is not $BRANCH_TO_CHECK. Found $GIT_BRANCH. Aborting script"
#  exit 1
#fi

DATACLAY_VERSION=$(cat $SCRIPTDIR/VERSION.txt)
DATACLAY_VERSION="${DATACLAY_VERSION//.dev/}"
DATACLAY_VERSION_TAG="$(get_container_version)"
IMAGES_STR=""
for element in "${IMAGES[@]}"; do
    IMAGES_STR="$element $IMAGES_STR"
done
IMAGES_TYPES_STR=""
for element in "${IMAGE_TYPES[@]}"; do
    IMAGES_TYPES_STR="$element $IMAGES_TYPES_STR"
done

SECONDS=0
printInfo "Deploying $DATACLAY_VERSION_TAG version"
printInfo "Images being deployed: $IMAGES_STR"
printInfo "Image types deployed: $IMAGES_TYPES_STR"
SECONDS=0
prepare_docker_buildx
for IMAGE_TYPE in "${IMAGE_TYPES[@]}"; do

  if [ ! -z $CONFIG_FILE ]; then
    source $CONFIG_FILE
  else
    source $SCRIPTDIR/common/${IMAGE_TYPE}.config
  fi
  if [ "$IMAGE_TYPE" == "normal" ]; then
    DOCKERFILE="-f Dockerfile"
    TAG_SUFFIX=""
  else
    DOCKERFILE="-f ${IMAGE_TYPE}.Dockerfile"
    TAG_SUFFIX="-${IMAGE_TYPE}"
  fi

  DEFAULT_TAG="${DATACLAY_VERSION_TAG}${TAG_SUFFIX}"
  DEFAULT_JDK_TAG="$(get_container_version jdk$DEFAULT_JAVA)${TAG_SUFFIX}"
  DEFAULT_PY_TAG="$(get_container_version py$DEFAULT_PYTHON)${TAG_SUFFIX}"

  PLATFORMS_COMMAND="--platform $PLATFORMS"
  if [ $LOCAL == true ]; then
    PLATFORMS_COMMAND=""
  fi
  # PACKAGE
  pushd $SCRIPTDIR/logicmodule
  docker build -f packager.Dockerfile -t bscdataclay/javaclay .
  popd

  for IMAGE in "${IMAGES[@]}"; do
    deploy_$IMAGE
  done
done


duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
echo "dataClay deployment FINISHED! "

#!/bin/bash
set -e
SCRIPTDIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
#-----------------------------------------------------------------------
# Helper functions (miscellaneous)
#-----------------------------------------------------------------------
CONSOLE_CYAN="\033[1m\033[36m"; CONSOLE_NORMAL="\033[0m"; CONSOLE_RED="\033[1m\033[91m"
printMsg() {
  printf "${CONSOLE_CYAN}${1}${CONSOLE_NORMAL}\n"
}
printError() {
  printf "${CONSOLE_RED}${1}${CONSOLE_NORMAL}\n"
}
#-----------------------------------------------------------------------
# MAIN
#-----------------------------------------------------------------------
DEV=false
DEV_ARG=""
PROMPT=true
PROMPT_ARG=""
BRANCH_TO_CHECK="master"
while test $# -gt 0
do
    case "$1" in
        --dev)
          DEV=true
          DEV_ARG="--dev"
          BRANCH_TO_CHECK="develop"
            ;;
        -y)
        	PROMPT=false
        	PROMPT_ARG="-y"
        	;;
        *) echo "Bad option $1"
        	exit 1
            ;;
    esac
    shift
done

printMsg "Welcome to dataClay release script"
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$GIT_BRANCH" != "$BRANCH_TO_CHECK" ]]; then
  printError "Branch is not $BRANCH_TO_CHECK. Aborting script";
  exit 1;
fi

read -p "Did you release javaclay and pyclay? (y/n) " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
  printError "Please release both packages first"
fi

if [ "$DEV" = false ] ; then
  cd $SCRIPTDIR/orchestration
  ./release.sh $PROMPT_ARG
  cd $SCRIPTDIR
fi

cd $SCRIPTDIR/docker
# TODO: make sure dspython requirements are pushed
VERSION=$(cat VERSION.txt)
VERSION="${VERSION//.dev/}"
echo "${VERSION}" > VERSION.txt
./deploy.sh $DEV_ARG $PROMPT_ARG --release
git add VERSION.txt

cd $SCRIPTDIR/hpc/mn
./deploy.sh $DEV_ARG $PROMPT_ARG

if [ "$DEV" = false ] ; then
  printMsg "Post-processing files in master"
  export VERSION=$(cat $SCRIPTDIR/orchestration/VERSION.txt)
  export PREV_VERSION=$(echo "$VERSION - 0.1" | bc)
  export NEW_VERSION=$(echo "$VERSION + 0.1" | bc)
  GIT_TAG=$VERSION

  # Update all submodules recursively
  # Add submodule changes
  git add docker/logicmodule/javaclay/
  git add docker/dspython/pyclay
  git add orchestration
  # Modify README.md
  sed -i "s/\.dev//g" README.md
  sed -i "s/develop-//g" README.md
  sed -i "s/develop/latest/g" README.md

  git add README.md
  git commit -m "Release ${GIT_TAG}"
  git push

  printMsg "Tagging new release in Git"
  git tag -a ${GIT_TAG} -m "Release ${GIT_TAG}"
  git push origin ${GIT_TAG}

  printMsg "Preparing develop branch"
  ## update develop branch also ##
  git checkout develop
  git merge master
  bash misc/prepare_dev_readme.sh

  pushd $SCRIPTDIR/docker/logicmodule/javaclay/ && git checkout develop && popd
  pushd $SCRIPTDIR/docker/dspython/pyclay && git checkout develop && popd
  pushd $SCRIPTDIR/orchestration && git checkout develop && popd

  # Add submodule changes
  git add docker/logicmodule/javaclay/
  git add docker/dspython/pyclay
  git add orchestration
  git add README.md
  git commit -m "Preparing new development version"
  git push

  # back to master
  git checkout master
fi

printMsg "dataClay successfully released! :)"

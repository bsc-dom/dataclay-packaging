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
GIT_BRANCH=$(git name-rev --name-only HEAD)
if [[ "$GIT_BRANCH" != "$BRANCH_TO_CHECK" ]]; then
  printError "Branch is not $BRANCH_TO_CHECK. Aborting script";
  exit 1;
fi

cd $SCRIPTDIR/docker/dspython/pyclay
./release.sh $DEV_ARG $PROMPT_ARG

cd $SCRIPTDIR/docker/logicmodule/javaclay
./release.sh $DEV_ARG $PROMPT_ARG

cd $SCRIPTDIR/docker
./deploy.sh $DEV_ARG $PROMPT_ARG
./deploy.sh $DEV_ARG $PROMPT_ARG --slim
./deploy.sh $DEV_ARG $PROMPT_ARG --alpine

if [ "$DEV" = false ] ; then

  cd $SCRIPTDIR/orchestration
  ./release.sh $PROMPT_ARG
  cd $SCRIPTDIR

  printMsg "Post-processing files in master"
  VERSION=$(cat $SCRIPTDIR/orchestration/VERSION.txt)
  PREV_VERSION=$(echo "$VERSION - 0.1" | bc)
  NEW_VERSION=$(echo "$VERSION + 0.1" | bc)
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
  git push origin master

  printMsg "Tagging new release in Git"
  git tag -a ${GIT_TAG} -m "Release ${GIT_TAG}"
  git push origin ${GIT_TAG}

  printMsg "Preparing develop branch"
  ## update develop branch also ##
  git fetch --all
  git checkout develop
  git merge master

  sed -i "s/$VERSION/$NEW_VERSION/g" README.md
  sed -i "s/$PREV_VERSION/$VERSION/g" README.md

  git add README.md
  git commit -m "Updating README.md"
  git push origin develop

  # back to master
  git checkout master
fi

cd $SCRIPTDIR/supercomputers/marenostrum
./deploy.sh $DEV_ARG

printMsg "dataClay successfully released! :)"

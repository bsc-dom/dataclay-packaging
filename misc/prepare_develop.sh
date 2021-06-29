#!/bin/bash
set -e
SCRIPTDIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
BASEDIR=$SCRIPTDIR/..
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

printMsg "Preparing develop branch"
## update develop branch also ##
git checkout develop
git merge master
bash $SCRIPTDIR/prepare_dev_readme.sh

pushd $BASEDIR/docker/logicmodule/javaclay/ && git checkout develop && popd
pushd $BASEDIR/docker/dspython/pyclay && git checkout develop && popd
pushd $BASEDIR/orchestration && git checkout develop && popd

# Add submodule changes
git add $BASEDIR/docker/logicmodule/javaclay/
git add $BASEDIR/docker/dspython/pyclay
git add $BASEDIR/orchestration
git add $BASEDIR/README.md
git commit -m "Preparing new development version"
git push
#!/bin/bash

################################## OPTIONS #############################################
export DEV=false
FLAGS=""
BRANCH=""
# idiomatic parameter and option handling in sh
while test $# -gt 0
do
    case "$1" in
        --dev) 
        	export DEV=true
            FLAGS="--dev"
            BRANCH="develop"
            ;;
        --master) 
        	BRANCH="master"
        	;;
        --*) echo "bad option $1"
        	exit -1
            ;;
        *) echo "bad option $1"
        	exit -1
            ;;
    esac
    shift
done
################################## MAIN #############################################

declare -r SSH_FILE="$(mktemp -u $HOME/.ssh/XXXXX)"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Decrypt the file containing the private key

openssl aes-256-cbc \
    -K $encrypted_8ebb1ef83f64_key \
    -iv $encrypted_8ebb1ef83f64_iv \
    -in ".travis/github/github_deploy_key.enc" \
    -out "$SSH_FILE" -d

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Enable SSH authentication

chmod 600 "$SSH_FILE" \
    && printf "%s\n" \
         "Host github.com" \
         "  IdentityFile $SSH_FILE" \
         "  LogLevel ERROR" >> ~/.ssh/config
         
git remote set-url origin git@github.com:bsc-dom/dataclay-packaging.git

# Update submodules
pushd logicmodule/javaclay/
git checkout $BRANCH
git pull
popd

pushd dspython/pyclay
git checkout $BRANCH
git pull
popd 

# Add submodule changes
git add logicmodule/javaclay/
git add dspython/pyclay

git commit -m "Updating sub-modules from TravisCI build $TRAVIS_BUILD_NUMBER"
git push origin HEAD:$BRANCH

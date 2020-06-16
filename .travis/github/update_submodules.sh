#!/bin/bash
DEPLOYSCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
PACKAGING_DIR=$DEPLOYSCRIPTDIR/../..
ORCHESTRATION_DIR=$PACKAGING_DIR/orchestration
source $PACKAGING_DIR/common/config.sh "$@"

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
pushd docker/logicmodule/javaclay/
git checkout $BRANCH
git pull
popd

pushd docker/dspython/pyclay
git checkout $BRANCH
git pull
popd 

pushd orchestration
git checkout $BRANCH
git pull
popd 

# Add submodule changes
git add docker/logicmodule/javaclay/
git add docker/dspython/pyclay
git add orchestration

git commit -m "Updating submodules"
git push origin HEAD:$BRANCH

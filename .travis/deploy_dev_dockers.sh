#!/bin/bash

# Update submodules
pushd logicmodule/javaclay/
git pull
popd

pushd dspython/pyclay
git pull
popd 

# Add submodule changes
git add logicmodule/javaclay/
git add dspython/pyclay

git commit -m "Updating sub-modules from TravisCI build $TRAVIS_BUILD_NUMBER"
git push origin develop

# Login in Dockerhub
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

# Deploy dockers
./deploy_dockers.sh --dev 


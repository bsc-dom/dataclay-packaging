#!/bin/bash
# Update submodules
pushd logicmodule/javaclay/
git checkout develop
git pull
popd

pushd dspython/pyclay
git checkout develop
git pull
popd 

# Add submodule changes
git add logicmodule/javaclay/
git add dspython/pyclay

git commit -m "Updating sub-modules from TravisCI build $TRAVIS_BUILD_NUMBER"
git push origin HEAD:develop

# Login in Dockerhub
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

export DEV=true
# Deploy dockers
./docker_deploy.sh --dev -y

# Deploy singularity 
./singularity_build.sh --dev
./singularity_deploy.sh --dev
source ./get_tags.sh

# Deploy singularity and orchestration scripts to Marenostrum
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r ./orchestration dataclay@dt01.bsc.es:/gpfs/apps/MN4/DATACLAY/$DEFAULT_TAG
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r ./singularity/* dataclay@dt01.bsc.es:/gpfs/apps/MN4/DATACLAY/$DEFAULT_TAG/images

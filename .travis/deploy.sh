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

# Login in Dockerhub
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

# Deploy dockers
./docker_deploy.sh $FLAGS -y

# Deploy singularity 
./singularity_build.sh $FLAGS
./singularity_deploy.sh $FLAGS
source ./get_tags.sh
# Deploy singularity and orchestration scripts to Marenostrum
scp -r ./orchestration dataclay@dt01.bsc.es:/gpfs/apps/MN4/DATACLAY/$DEFAULT_TAG
scp -r ./singularity/* dataclay@dt01.bsc.es:/gpfs/apps/MN4/DATACLAY/$DEFAULT_TAG/images

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

# Login in Dockerhub
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

# Deploy dockers
./docker_deploy.sh $FLAGS -y

# Deploy singularity 
./singularity_build.sh $FLAGS
./singularity_deploy.sh $FLAGS
source ./config.sh
# Deploy singularity and orchestration scripts to Marenostrum
scp -r ./orchestration dataclay@dt01.bsc.es:/gpfs/apps/MN4/DATACLAY/$DEFAULT_TAG
scp -r ./singularity/* dataclay@dt01.bsc.es:/gpfs/apps/MN4/DATACLAY/$DEFAULT_TAG/images

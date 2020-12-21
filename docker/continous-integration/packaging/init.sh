#!/bin/bash
cd /appveyor/projects/dataclay-packaging

# Initialize submodules
git submodule init
git submodule update

# Login in Dockerhub
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
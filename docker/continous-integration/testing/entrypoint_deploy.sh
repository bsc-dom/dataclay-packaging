#!/bin/bash
# Initialize submodules
git submodule init
git submodule update

# Init docker session
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

exec $@
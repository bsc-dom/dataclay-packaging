#!/bin/bash
if [[ $TRAVIS_EVENT_TYPE == 'cron' ]]; then 
    echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
    ./deploy_dockers.sh --dev 
else 
    echo "Skipping. Only deploying dev dockers on cron job" 
fi


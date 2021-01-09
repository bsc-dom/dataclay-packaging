#!/bin/bash

# Install  keys
mkdir -p $HOME/.ssh
/appveyor-tools/secure-file -decrypt .appveyor/mn_deploy_key.enc -secret $MN_SECRET -salt $MN_SALT
mv .appveyor/mn_deploy_key $HOME/.ssh/mn_deploy_key

# Configure ssh
chmod 600 "$HOME/.ssh/mn_deploy_key" \
    && printf "%s\n" \
         "Host *" \
         "  IdentityFile $HOME/.ssh/mn_deploy_key" \
         "  StrictHostKeyChecking no" \
         "  UserKnownHostsFile=/dev/null" >> $HOME/.ssh/config

# Run test
bash $@

# Publish results
ssh dataclay@mn1.bsc.es "mkdir -p ~/appveyor/testing-results/"
scp -r allure-results/* dataclay@mn1.bsc.es:~/appveyor/testing-results/

  

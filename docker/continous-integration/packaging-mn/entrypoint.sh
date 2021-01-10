#!/bin/bash

# Initialize submodules
git submodule init
git submodule update

# Install  keys
/appveyor-tools/secure-file -decrypt .appveyor/mn_deploy_key.enc -secret $MN_SECRET -salt $MN_SALT
mv .appveyor/mn_deploy_key $HOME/.ssh/mn_deploy_key

# Configure ssh
chmod 600 "$HOME/.ssh/mn_deploy_key" \
    && printf "%s\n" \
         "Host *" \
         "  IdentityFile $HOME/.ssh/mn_deploy_key" \
         "  StrictHostKeyChecking no" \
         "  UserKnownHostsFile=/dev/null" >> $HOME/.ssh/config

exec $@
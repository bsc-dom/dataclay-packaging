#!/bin/bash

# Install  keys
/appveyor-tools/secure-file -decrypt .appveyor/mn_deploy_key.enc -secret $MN_SECRET -salt $MN_SALT
/appveyor-tools/secure-file -decrypt .appveyor/github_deploy_key.enc -secret $GITHUB_SECRET -salt $GITHUB_SALT
mv .appveyor/mn_deploy_key $HOME/.ssh/mn_deploy_key
mv .appveyor/github_deploy_key $HOME/.ssh/github_deploy_key

# Configure ssh
chmod 600 "$HOME/.ssh/mn_deploy_key"
chmod 600 "$HOME/.ssh/github_deploy_key"
printf "%s\n" \
         "Host mn1.bsc.es" \
         "  IdentityFile $HOME/.ssh/mn_deploy_key" \
         "  StrictHostKeyChecking no" \
         "  UserKnownHostsFile=/dev/null" >> $HOME/.ssh/config
printf "%s\n" \
         "Host dt01.bsc.es" \
         "  IdentityFile $HOME/.ssh/mn_deploy_key" \
         "  StrictHostKeyChecking no" \
         "  UserKnownHostsFile=/dev/null" >> $HOME/.ssh/config
printf "%s\n" \
         "Host *" \
         "  StrictHostKeyChecking no" \
         "  UserKnownHostsFile=/dev/null" >> ~/.ssh/config
printf "%s\n" \
         "Host github.com" \
         "  IdentityFile $HOME/.ssh/github_deploy_key" \
         "  StrictHostKeyChecking no" \
         "  UserKnownHostsFile=/dev/null" >> $HOME/.ssh/config

exec $@
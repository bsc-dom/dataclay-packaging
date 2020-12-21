#!/bin/bash
# Install mn keys
echo "-----BEGIN RSA PRIVATE KEY-----" > $HOME/.ssh/mn_deploy_key
echo $MN_PRIVATE_KEY >> $HOME/.ssh/mn_deploy_key
echo "-----END RSA PRIVATE KEY-----" >> $HOME/.ssh/mn_deploy_key
#mv .appveyor/mn_deploy_key $HOME/.ssh/mn_deploy_key
chmod 600 "$HOME/.ssh/mn_deploy_key" \
    && printf "%s\n" \
         "Host *" \
         "  IdentityFile $HOME/.ssh/mn_deploy_key" \
         "  StrictHostKeyChecking no" \
         "  UserKnownHostsFile=/dev/null" >> $HOME/.ssh/config

#!/bin/bash

declare -r SSH_FILE="$(mktemp -u $HOME/.ssh/XXXXX)"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Decrypt the file containing the private key

openssl aes-256-cbc \
	-K $encrypted_12a78a482e9b_key \
	-iv $encrypted_12a78a482e9b_iv \
	-in .travis/marenostrum/marenostrum_deploy_key.enc \
	-out "$SSH_FILE" -d

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Enable SSH authentication

chmod 600 "$SSH_FILE" \
    && printf "%s\n" \
         "Host dt01.bsc.es" \
         "  IdentityFile $SSH_FILE" \
         "  LogLevel ERROR" >> ~/.ssh/config

source ./common/config.sh "$@"

LOCAL_REPOSITORY=$(mktemp -d -t marenostrum-XXXXXXXXXX)
singularity pull $LOCAL_REPOSITORY/logicmodule.sif library://support-dataclay/default/logicmodule:$DEFAULT_TAG
singularity pull $LOCAL_REPOSITORY/dsjava.sif library://support-dataclay/default/dsjava:$DEFAULT_TAG
singularity pull $LOCAL_REPOSITORY/dspython.sif library://support-dataclay/default/dspython:$DEFAULT_TAG
singularity pull $LOCAL_REPOSITORY/client.sif library://support-dataclay/default/client:$DEFAULT_TAG

chmod 600 "$SSH_FILE" \
    && printf "%s\n" \
         "Host *" \
         "  StrictHostKeyChecking no" \
         "  UserKnownHostsFile=/dev/null" >> ~/.ssh/config

# Deploy singularity and orchestration scripts to Marenostrum
scp -r ./orchestration dataclay@dt01.bsc.es:/gpfs/apps/MN4/DATACLAY/$DEFAULT_TAG
scp -r $LOCAL_REPOSITORY/ dataclay@dt01.bsc.es:/gpfs/apps/MN4/DATACLAY/$DEFAULT_TAG/singularity/images/
ssh dataclay@mn1.bsc.es "echo $DEFAULT_TAG > /apps/MN4/DATACLAY/$DEFAULT_TAG/VERSION.txt"
ssh dataclay@mn1.bsc.es "/apps/MN4/DATACLAY/$DEFAULT_TAG/install_client_dependencies.sh"
#--prolog \"module load gcc/7.2.0 EXTRAE/3.6.1\""

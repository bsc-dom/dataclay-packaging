#!/bin/bash
declare -r SSH_FILE="$(mktemp -u $HOME/.ssh/XXXXX)"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Decrypt the file containing the private key
openssl aes-256-cbc \
	-K $encrypted_12a78a482e9b_key -iv $encrypted_12a78a482e9b_iv \
	-in .travis/marenostrum/marenostrum_deploy_key.enc \
	-out "$SSH_FILE" -d

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Enable SSH authentication
chmod 600 "$SSH_FILE" \
    && printf "%s\n" \
         "Host dt01.bsc.es" \
         "  IdentityFile $SSH_FILE" \
         "  LogLevel ERROR" >> ~/.ssh/config \
    && printf "%s\n" \
         "Host mn1.bsc.es" \
         "  IdentityFile $SSH_FILE" \
         "  LogLevel ERROR" >> ~/.ssh/config
         
chmod 600 "$SSH_FILE" \
    && printf "%s\n" \
         "Host *" \
         "  StrictHostKeyChecking no" \
         "  UserKnownHostsFile=/dev/null" >> ~/.ssh/config

source ./common/config.sh "$@"
if [ -z $DEFAULT_TAG ]; then 
	echo "CRITICAL: DEFAULT_TAG not set. Aborting." 
	exit 1 
fi

# Pull singularity images if needed
LOCAL_REPOSITORY=$(mktemp -d -t marenostrum-XXXXXXXXXX)
singularity pull $LOCAL_REPOSITORY/logicmodule.sif library://support-dataclay/default/logicmodule:$DEFAULT_TAG
singularity pull $LOCAL_REPOSITORY/dsjava.sif library://support-dataclay/default/dsjava:$DEFAULT_TAG
singularity pull $LOCAL_REPOSITORY/dspython.sif library://support-dataclay/default/dspython:$DEFAULT_TAG
singularity pull $LOCAL_REPOSITORY/client.sif library://support-dataclay/default/client:$DEFAULT_TAG

# Prepare module definition 
sed "s/SET_VERSION_HERE/${DEFAULT_TAG}/g" ./.travis/marenostrum/module.lua > /tmp/${DEFAULT_TAG}.lua

# Deploy singularity and orchestration scripts to Marenostrum
ssh dataclay@mn1.bsc.es "rm -rf /apps/DATACLAY/$DEFAULT_TAG/ && mkdir -p /apps/DATACLAY/$DEFAULT_TAG/singularity/images/" #sanity check

scp -r ./orchestration/* dataclay@dt01.bsc.es:/gpfs/apps/MN4/DATACLAY/$DEFAULT_TAG
scp $LOCAL_REPOSITORY/* dataclay@dt01.bsc.es:/gpfs/apps/MN4/DATACLAY/$DEFAULT_TAG/singularity/images/

# Module definition
scp /tmp/${DEFAULT_TAG}.lua dataclay@dt01.bsc.es:/gpfs/apps/MN4/DATACLAY/modules/
MODULE_LINK="develop"
if [ "$DEV" = false ] ; then
	MODULE_LINK="latest"
fi
ssh dataclay@mn1.bsc.es "rm /apps/DATACLAY/modules/${MODULE_LINK}.lua && ln -s /apps/DATACLAY/modules/${DEFAULT_TAG}.lua /apps/DATACLAY/modules/${MODULE_LINK}.lua"
ssh dataclay@mn1.bsc.es "echo $DEFAULT_TAG > /apps/DATACLAY/$DEFAULT_TAG/VERSION.txt"

# Singularity is needed to install client dependencies
ssh dataclay@mn1.bsc.es "module load GCC/7.2.0 EXTRAE/3.6.1 SINGULARITY/3.5.2 && /apps/DATACLAY/$DEFAULT_TAG/client/install_client_dependencies.sh"

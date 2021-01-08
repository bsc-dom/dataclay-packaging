
#!/bin/bash
DEPLOYSCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
PACKAGING_DIR=$DEPLOYSCRIPTDIR/../..
ORCHESTRATION_DIR=$PACKAGING_DIR/orchestration
source $PACKAGING_DIR/common/config.sh "$@"
if [ -z $DEFAULT_TAG ]; then
	echo "CRITICAL: DEFAULT_TAG not set. Aborting."
	exit 1
fi

SECONDS=0
echo "[marenostrum-deploy] Deploying to MN..."

# Prepare module definition
sed "s/SET_VERSION_HERE/${DEFAULT_TAG}/g" $DEPLOYSCRIPTDIR/module.lua > /tmp/${DEFAULT_TAG}.lua

# Deploy singularity and orchestration scripts to Marenostrum
DEPLOY_CMD="rm -rf /apps/DATACLAY/$DEFAULT_TAG/ &&\
 mkdir -p /apps/DATACLAY/$DEFAULT_TAG/singularity/images/ &&\
 mkdir -p /apps/DATACLAY/$DEFAULT_TAG/javaclay &&\
 mkdir -p /apps/DATACLAY/$DEFAULT_TAG/pyclay"

echo "[marenostrum-deploy] Cleaning and preparing folders in MN..."
ssh dataclay@mn2.bsc.es "$DEPLOY_CMD"

# Send orchestration script and images
echo "[marenostrum-deploy] Deploying dataclay orchestrator and singularity images..."
rsync -av -e ssh $PACKAGING_DIR/orchestration/* dataclay@dt01.bsc.es:/gpfs/apps/MN4/DATACLAY/$DEFAULT_TAG

# Send javaclay and pyclay
echo "[marenostrum-deploy] Deploying javaclay..."
pushd $PACKAGING_DIR/docker/logicmodule/javaclay
mvn package -DskipTests=true
scp target/*-jar-with-dependencies.jar dataclay@dt01.bsc.es:/gpfs/apps/MN4/DATACLAY/$DEFAULT_TAG/javaclay/dataclay.jar
popd
echo "[marenostrum-deploy] Deploying pyclay..."
rsync -av -e ssh --progress $PACKAGING_DIR/docker/dspython/pyclay/* dataclay@dt01.bsc.es:/gpfs/apps/MN4/DATACLAY/$DEFAULT_TAG/pyclay/

# Changing permissions in pyclay folder
ssh dataclay@mn2.bsc.es "chmod -R g-w /apps/DATACLAY/$DEFAULT_TAG/pyclay/"

# Module definition
echo "[marenostrum-deploy] Deploying dataclay module..."
scp /tmp/${DEFAULT_TAG}.lua dataclay@dt01.bsc.es:/gpfs/apps/MN4/DATACLAY/modules/
MODULE_LINK="develop"
if [ "$DEV" = false ] ; then
	MODULE_LINK="latest"
fi
ssh dataclay@mn2.bsc.es "rm /apps/DATACLAY/modules/${MODULE_LINK}.lua && ln -s /apps/DATACLAY/modules/${DEFAULT_TAG}.lua /apps/DATACLAY/modules/${MODULE_LINK}.lua"

duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
echo "MN deployment successfully finished!"

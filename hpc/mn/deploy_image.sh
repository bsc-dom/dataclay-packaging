#!/bin/bash
DEPLOYSCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
PACKAGING_DIR=$DEPLOYSCRIPTDIR/../..
ORCHESTRATION_DIR=$PACKAGING_DIR/orchestration
source $PACKAGING_DIR/common/config.sh "$@"
if [ -z $DEFAULT_TAG ]; then
	echo "CRITICAL: DEFAULT_TAG not set. Aborting."
	exit 1
fi
if [ -z $EXECUTION_ENVIRONMENT_TAG ]; then EXECUTION_ENVIRONMENT_TAG=$DEFAULT_TAG; fi

SECONDS=0

echo "[marenostrum-deploy] Deploying image to MN..."

singularity pull $DEPLOYSCRIPTDIR/${SINGULARITY_IMG}:${EXECUTION_ENVIRONMENT_TAG}.sif docker://bscdataclay/${SINGULARITY_IMG}:$EXECUTION_ENVIRONMENT_TAG
scp $DEPLOYSCRIPTDIR/${SINGULARITY_IMG}:${EXECUTION_ENVIRONMENT_TAG}.sif dataclay@dt01.bsc.es:/gpfs/apps/MN4/DATACLAY/$DEFAULT_TAG/singularity/images/

duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
echo "MN deployment successfully finished!"
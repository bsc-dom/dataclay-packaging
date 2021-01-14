#!/bin/bash -e
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
$SCRIPTDIR/deploy.sh --dev -y
$SCRIPTDIR/deploy.sh --dev -y --slim
$SCRIPTDIR/deploy.sh --dev -y --alpine
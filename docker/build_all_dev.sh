#!/bin/bash -e
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
$SCRIPTDIR/build.sh --dev -y
$SCRIPTDIR/build.sh --dev -y --slim
$SCRIPTDIR/build.sh --dev -y --alpine
#!/bin/bash -e
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
$SCRIPTDIR/deploy.sh --dev -y --arm32 --add-date-tag
$SCRIPTDIR/deploy.sh --dev -y --add-date-tag
$SCRIPTDIR/deploy.sh --dev -y --slim --add-date-tag
$SCRIPTDIR/deploy.sh --dev -y --alpine --add-date-tag

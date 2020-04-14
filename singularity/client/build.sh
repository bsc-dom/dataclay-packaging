#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BUILDDIR/../../common/config.sh

IMAGE_NAME=client
TAG=$CLIENT_TAG
source $BUILDDIR/../misc/_build.sh

rm -f $REPOSITORY/client.sif 
ln -s $REPOSITORY/client.${CLIENT_TAG}.sif $REPOSITORY/client.sif

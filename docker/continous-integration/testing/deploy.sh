#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
pushd $BUILDDIR
docker build -t dom-ci.bsc.es/bscdataclay/continuous-integration:testing .
docker push dom-ci.bsc.es/bscdataclay/continuous-integration:testing
popd

echo " ===== Done! ====="




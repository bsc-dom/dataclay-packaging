#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
pushd $BUILDDIR
docker build -t bscdataclay/continuous-integration:reporting .
docker push bscdataclay/continuous-integration:reporting
popd

echo " ===== Done! ====="




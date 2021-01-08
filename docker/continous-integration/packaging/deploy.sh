#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
pushd $BUILDDIR
docker build -t bscdataclay/continuous-integration:packaging .
docker push bscdataclay/continuous-integration:packaging

popd

echo " ===== Done! ====="




#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
pushd $BUILDDIR

docker build -f Dockerfile -t bscdataclay/continuous-integration:packaging .
docker build -f mn.Dockerfile -t bscdataclay/continuous-integration:packaging-mn .
docker push bscdataclay/continuous-integration:packaging
docker push bscdataclay/continuous-integration:packaging-mn

popd

echo " ===== Done! ====="




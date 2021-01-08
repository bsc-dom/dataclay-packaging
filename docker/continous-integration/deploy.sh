#!/bin/bash
BUILDDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
for DIR in $BUILDDIR/*; do
  if [ -d $DIR ]; then
    pushd $DIR
    ./deploy.sh
    popd
  fi
done



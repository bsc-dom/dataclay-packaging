#!/bin/bash
SCRIPTDIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
BASEDIR=$SCRIPTDIR/..
export VERSION=$(cat $BASEDIR/orchestration/VERSION.txt)
VERSION="${VERSION//.dev/}"
export PREV_VERSION=$(echo "$VERSION - 0.1" | bc)
export NEW_VERSION=$(echo "$VERSION + 0.1" | bc)
echo "VERSION = $VERSION"
echo "PREV_VERSION = $PREV_VERSION"
echo "NEW_VERSION = $NEW_VERSION"
cd $BASEDIR
sed -i "s/latest/develop/g" README.md
sed -i "s/\:slim/\:develop-slim/g" README.md
sed -i "s/\:alpine/\:develop-alpine/g" README.md
sed -i "s/\/slim/\/develop-slim/g" README.md
sed -i "s/\/alpine/\/develop-alpine/g" README.md
sed -i "s/jdk8/jdk8.dev/g" README.md
sed -i "s/jdk11/jdk11.dev/g" README.md
sed -i "s/py36/py36.dev/g" README.md
sed -i "s/py37/py37.dev/g" README.md
sed -i "s/py38/py38.dev/g" README.md
sed -i "s/\`slim/\`develop-slim/g" README.md
sed -i "s/\`alpine/\`develop-alpine/g" README.md
sed -i "s/$VERSION-/$NEW_VERSION.dev-/g" README.md
sed -i "s/$VERSION\`/$NEW_VERSION.dev\`/g" README.md
sed -i "s/$VERSION.jdk/$NEW_VERSION.jdk/g" README.md
sed -i "s/$VERSION.py/$NEW_VERSION.py/g" README.md
sed -i "s/$PREV_VERSION/$VERSION/g" README.md
cd $SCRIPTDIR
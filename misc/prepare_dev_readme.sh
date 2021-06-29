#!/bin/bash
sed -i "s/latest/develop/g" $BASEDIR/README.md
sed -i "s/\:slim/\:develop-slim/g" $BASEDIR/README.md
sed -i "s/\:alpine/\:develop-alpine/g" $BASEDIR/README.md
sed -i "s/\/slim/\/develop-slim/g" $BASEDIR/README.md
sed -i "s/\/alpine/\/develop-alpine/g" $BASEDIR/README.md
sed -i "s/jdk8/jdk8.dev/g" $BASEDIR/README.md
sed -i "s/jdk11/jdk11.dev/g" $BASEDIR/README.md
sed -i "s/py36/py36.dev/g" $BASEDIR/README.md
sed -i "s/py37/py37.dev/g" $BASEDIR/README.md
sed -i "s/py38/py38.dev/g" $BASEDIR/README.md
sed -i "s/\`slim/\`develop-slim/g" $BASEDIR/README.md
sed -i "s/\`alpine/\`develop-alpine/g" $BASEDIR/README.md
sed -i "s/$VERSION-/$NEW_VERSION.dev-/g" $BASEDIR/README.md
sed -i "s/$VERSION\`/$NEW_VERSION.dev\`/g" $BASEDIR/README.md
sed -i "s/$VERSION.jdk/$NEW_VERSION.jdk/g" $BASEDIR/README.md
sed -i "s/$VERSION.py/$NEW_VERSION.py/g" $BASEDIR/README.md
sed -i "s/$PREV_VERSION/$VERSION/g" $BASEDIR/README.md

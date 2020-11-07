#!/bin/bash
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

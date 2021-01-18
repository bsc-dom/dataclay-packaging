#!/bin/bash
BUILDERS=$(docker buildx ls | awk '{print $1'} | grep -v "default" | grep -v "NAME")
for BUILDER in $BUILDERS; do
  docker buildx rm $BUILDER
done
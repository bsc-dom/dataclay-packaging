#!/bin/bash
# Initialize submodules
git submodule init
git submodule update

exec $@
#!/bin/bash
sudo apt-get update && sudo apt-get install -y \
    build-essential \
    libssl-dev \
    uuid-dev \
    libgpgme11-dev \
    squashfs-tools \
    libseccomp-dev \
    wget \
    pkg-config \
    git \
    cryptsetup

# Install go
eval "$(gimme $TRAVIS_GO_VERSION)"

export VERSION=3.5.2
wget --quiet https://github.com/sylabs/singularity/releases/download/v${VERSION}/singularity-${VERSION}.tar.gz
tar -xzf singularity-${VERSION}.tar.gz 

pushd singularity
./mconfig && \
    make -C builddir && \
    sudo make -C builddir install

popd


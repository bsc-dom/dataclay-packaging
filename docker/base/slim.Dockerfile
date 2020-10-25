#############################################
# Base Dockerfile for dataClay  #
#############################################
FROM ubuntu:18.04
### Extend from ubuntu instead of openjdk specialized image to allow multiple architectures
LABEL org.opencontainers.image.title="dataClay base image" \
      org.opencontainers.image.description="Active objects across the network" \
      org.opencontainers.image.url="https://dataclay.bsc.es/" \
      org.label-schema.vcs-url="https://github.com/bsc-dom/dataclay-packaging" \
      org.opencontainers.image.vendor="Barcelona Supercomputing Center (BSC-CNS)" \
      org.opencontainers.image.authors="support-dataclay@bsc.es" \
      org.opencontainers.image.licenses="BSD-3-Clause" \
      org.label-schema.docker.dockerfile="/docker/base/slim.Dockerfile"
# ============ PRE-INSTALLATION ================== #
# Install packages:
RUN apt-get update \
        && apt-get install --no-install-recommends -y --allow-unauthenticated sqlite3 libsqlite3-0 >/dev/null \
        && rm -rf /var/lib/apt/lists/*
# Working dir 
ENV DATACLAY_HOME=/home/dataclayusr/dataclay
RUN mkdir -p ${DATACLAY_HOME}
WORKDIR ${DATACLAY_HOME}
# ================= SERVICE ==================== #
ENTRYPOINT ["echo", "This is dataClay's base image: nothing to do here"] 

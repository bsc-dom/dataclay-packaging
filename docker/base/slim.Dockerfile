#############################################
# Base Dockerfile for dataClay  #
#############################################
FROM ubuntu:18.04
LABEL maintainer dataClay team <support-dataclay@bsc.es>
### Extend from ubuntu instead of openjdk specialized image to allow multiple architectures
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

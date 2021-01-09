#############################################
# Base Dockerfile for dataClay  #
#############################################
FROM alpine:3
ARG BUILD_DATE
ARG VCS_REF
LABEL org.opencontainers.image.title="dataClay base image" \
      org.opencontainers.image.created=$BUILD_DATE \
      org.label-schema.vcs-ref=$VCS_REF \
      org.opencontainers.image.description="Active objects across the network" \
      org.opencontainers.image.url="https://dataclay.bsc.es/" \
      org.label-schema.vcs-url="https://github.com/bsc-dom/dataclay-packaging" \
      org.opencontainers.image.vendor="Barcelona Supercomputing Center (BSC-CNS)" \
      org.opencontainers.image.authors="support-dataclay@bsc.es" \
      org.opencontainers.image.licenses="BSD-3-Clause" \
      org.label-schema.docker.dockerfile="/docker/base/alpine.Dockerfile"
# ============ PRE-INSTALLATION ================== #
# Working dir 
ENV DATACLAY_HOME=/home/dataclayusr/dataclay
RUN mkdir -p ${DATACLAY_HOME}
WORKDIR ${DATACLAY_HOME}
# ================= SERVICE ==================== #
ENTRYPOINT ["echo", "This is dataClay's base image: nothing to do here"] 

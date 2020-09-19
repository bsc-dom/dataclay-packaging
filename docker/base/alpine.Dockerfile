#############################################
# Base Dockerfile for dataClay  #
#############################################
FROM alpine:3
LABEL maintainer dataClay team <support-dataclay@bsc.es>
# ============ PRE-INSTALLATION ================== #
# Working dir 
ENV DATACLAY_HOME=/home/dataclayusr/dataclay
RUN mkdir -p ${DATACLAY_HOME}
WORKDIR ${DATACLAY_HOME}
# ================= SERVICE ==================== #
ENTRYPOINT ["echo", "This is dataClay's base image: nothing to do here"] 

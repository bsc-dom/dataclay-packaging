# Add only our minimal "JRE" distr and our app
FROM alpine:3
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.opencontainers.image.title="dataClay logicmodule" \
      org.opencontainers.image.created=$BUILD_DATE \
      org.label-schema.vcs-ref=$VCS_REF \
      org.opencontainers.image.description="Active objects across the network" \
      org.opencontainers.image.url="https://dataclay.bsc.es/" \
      org.label-schema.vcs-url="https://github.com/bsc-dom/dataclay-packaging" \
      org.opencontainers.image.vendor="Barcelona Supercomputing Center (BSC-CNS)" \
      org.opencontainers.image.version=$VERSION \
      org.opencontainers.image.authors="support-dataclay@bsc.es" \
      org.opencontainers.image.licenses="BSD-3-Clause" \
      org.label-schema.docker.dockerfile="/docker/logicmodule/alpine.Dockerfile"

# Install packages:
RUN apk --no-cache --update add openjdk8-jre-base
RUN java -version
RUN apk --no-cache --update add sqlite

ENV DATACLAY_HOME=/home/dataclayusr/dataclay
ENV DATACLAY_LOG_CONFIG=${DATACLAY_HOME}/logging/log4j2.xml
ENV DATACLAY_JAR=${DATACLAY_HOME}/dataclay.jar
COPY logging/debug.xml ${DATACLAY_LOG_CONFIG}
ENV JAVA_HOME=${JAVA_MINIMAL}

RUN mkdir -p ${DATACLAY_HOME}
WORKDIR ${DATACLAY_HOME}

# Get dataClay JAR
COPY ./dataclay.jar ${DATACLAY_JAR}
# prepare storage dir
RUN mkdir -p /dataclay/storage

# Copy entrypoint
COPY ./dataclay-java-entry-point.sh ${DATACLAY_HOME}/entrypoints/dataclay-java-entry-point

# Modify path for entrypoints
ENV PATH=${DATACLAY_HOME}/entrypoints:${PATH}

# Copy healthcheck
COPY ./health_check.sh ${DATACLAY_HOME}/health/health_check.sh

# ================= SERVICE ==================== #
ENTRYPOINT ["dataclay-java-entry-point", "es.bsc.dataclay.logic.server.LogicModuleSrv"]

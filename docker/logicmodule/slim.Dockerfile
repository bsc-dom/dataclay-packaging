ARG BASE_VERSION
ARG REGISTRY=""
FROM ${REGISTRY}/base:${BASE_VERSION}
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
      org.label-schema.docker.dockerfile="/docker/logicmodule/slim.Dockerfile"

ARG JDK=11

# Install javaclay packages:
RUN apt-get update \
        && apt-get install --no-install-recommends -y --allow-unauthenticated openjdk-${JDK}-jdk >/dev/null\
        && rm -rf /var/lib/apt/lists/*
       
# Set Java home. We create a symbolic link to be arch-independant 
RUN ln -s /usr/lib/jvm/java-${JDK}-openjdk* /usr/lib/jvm/java-default
ENV JAVA_HOME=/usr/lib/jvm/java-default
RUN update-alternatives --install "/usr/bin/java" "java" ${JAVA_HOME}/bin/java 99999 && \
	update-alternatives --set java ${JAVA_HOME}/bin/java

# Configure dataclay environment variables
ENV DATACLAY_LOG_CONFIG=${DATACLAY_HOME}/logging/log4j2.xml
ENV DATACLAY_JAR=${DATACLAY_HOME}/dataclay.jar
COPY logging/debug.xml ${DATACLAY_LOG_CONFIG}

# Get dataClay JAR
COPY ./dataclay.jar ${DATACLAY_JAR}
# prepare storage dir
RUN mkdir -p /dataclay/storage
RUN mkdir -p /dataclay/metadata

# Copy entrypoint
COPY ./dataclay-java-entry-point.sh ${DATACLAY_HOME}/entrypoints/dataclay-java-entry-point
#COPY ./dataclay-mvn-entry-point.sh ${DATACLAY_HOME}/entrypoints/dataclay-mvn-entry-point

# Modify path for entrypoints
ENV PATH=${DATACLAY_HOME}/entrypoints:${PATH}

# Copy healthcheck
COPY ./health_check.sh ${DATACLAY_HOME}/health/health_check.sh

# ================= SERVICE ==================== #
ENTRYPOINT ["dataclay-java-entry-point", "es.bsc.dataclay.logic.server.LogicModuleSrv"]

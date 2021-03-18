FROM alpine:3 as minijdk
RUN apk --no-cache add openjdk11-jdk openjdk11-jmods
ENV JAVA_MINIMAL="/opt/java-minimal"
# build minimal JRE
RUN /usr/lib/jvm/java-11-openjdk/bin/jlink \
    --verbose \
    --add-modules java.base,java.logging,java.transaction.xa,jdk.compiler,jdk.jartool,jdk.zipfs,\
java.sql,java.naming,java.desktop,java.management,java.security.jgss,jdk.crypto.ec,java.instrument,\
jdk.unsupported,jdk.jdi,java.net.http \
    --compress 2 --strip-debug --no-header-files --no-man-pages \
    --release-info="add:IMPLEMENTOR=bsc:IMPLEMENTOR_VERSION=dataclay_JRE" \
    --output "$JAVA_MINIMAL"


# ============================================================ #
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
ENV JAVA_MINIMAL="/opt/java-minimal"
ENV PATH="$PATH:$JAVA_MINIMAL/bin"
COPY --from=minijdk "$JAVA_MINIMAL" "$JAVA_MINIMAL"
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

# Copy entrypoint
COPY ./dataclay-java-entry-point.sh ${DATACLAY_HOME}/entrypoints/dataclay-java-entry-point

# Modify path for entrypoints
ENV PATH=${DATACLAY_HOME}/entrypoints:${PATH}

# Copy healthcheck
COPY ./health_check.sh ${DATACLAY_HOME}/health/health_check.sh

# ================= SERVICE ==================== #
ENTRYPOINT ["dataclay-java-entry-point", "es.bsc.dataclay.logic.server.LogicModuleSrv"]

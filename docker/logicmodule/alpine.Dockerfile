FROM alpine:3 as packager
RUN apk --no-cache add openjdk11-jdk openjdk11-jmods
ENV JAVA_MINIMAL="/opt/java-minimal"
# build minimal JRE
RUN /usr/lib/jvm/java-11-openjdk/bin/jlink \
    --verbose \
    --add-modules java.base,java.logging,java.transaction.xa,java.compiler,\
java.sql,java.naming,java.desktop,java.management,java.security.jgss,jdk.crypto.ec,java.instrument,\
jdk.unsupported,jdk.jdi,java.net.http \
    --compress 2 --strip-debug --no-header-files --no-man-pages \
    --release-info="add:IMPLEMENTOR=bsc:IMPLEMENTOR_VERSION=dataclay_JRE" \
    --output "$JAVA_MINIMAL"
# Compile javaclay in a different layer with JDK (not JRE)
# ============================================================ #
FROM alpine:3 as javaclay-compiler
RUN apk --no-cache --update add openjdk11 maven
COPY ./javaclay /javaclay
RUN cd /javaclay && mvn clean package -DskipTests=true -Pslim
RUN ls -la /javaclay/target/*.jar
# ============================================================ #
# Add only our minimal "JRE" distr and our app
FROM alpine:3
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.title="dataClay client" \
      org.opencontainers.image.description="Active objects across the network" \
      org.opencontainers.image.url="https://dataclay.bsc.es/" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/bsc-dom/dataclay-packaging" \
      org.opencontainers.image.vendor="Barcelona Supercomputing Center (BSC-CNS)" \
      org.opencontainers.image.version=$VERSION \
      org.opencontainers.image.authors="support-dataclay@bsc.es" \
      org.opencontainers.image.licenses="BSD-3-Clause" \
      org.label-schema.docker.dockerfile="/docker/logicmodule/alpine.Dockerfile"

# Install packages:
ENV JAVA_MINIMAL="/opt/java-minimal"
ENV PATH="$PATH:$JAVA_MINIMAL/bin"
COPY --from=packager "$JAVA_MINIMAL" "$JAVA_MINIMAL"

RUN apk --no-cache --update add sqlite

ENV DATACLAY_HOME=/home/dataclayusr/dataclay
ENV DATACLAY_LOG_CONFIG=${DATACLAY_HOME}/logging/log4j2.xml
ENV DATACLAY_JAR=${DATACLAY_HOME}/dataclay.jar
COPY logging/debug.xml ${DATACLAY_LOG_CONFIG}
ENV JAVA_HOME=${JAVA_MINIMAL}

RUN mkdir -p ${DATACLAY_HOME}
WORKDIR ${DATACLAY_HOME}

# Get dataClay JAR
ARG JAR_VERSION
COPY --from=javaclay-compiler /javaclay/target/dataclay-${JAR_VERSION}-shaded.jar ${DATACLAY_JAR}
ENV CLASSPATH=${DATACLAY_JAR}:${CLASSPATH}

# Copy entrypoint
COPY ./dataclay-java-entry-point.sh ${DATACLAY_HOME}/entrypoints/dataclay-java-entry-point

# Modify path for entrypoints
ENV PATH=${DATACLAY_HOME}/entrypoints:${PATH}

# Copy healthcheck
COPY ./health_check.sh ${DATACLAY_HOME}/health/health_check.sh

# ================= SERVICE ==================== #
ENTRYPOINT ["dataclay-java-entry-point", "es.bsc.dataclay.logic.server.LogicModuleSrv"]

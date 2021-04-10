ARG DATACLAY_DSPYTHON_DOCKER_TAG
ARG DATACLAY_LOGICMODULE_DOCKER_TAG
ARG REGISTRY=""
FROM ${REGISTRY}/dspython:${DATACLAY_DSPYTHON_DOCKER_TAG}
FROM ${REGISTRY}/logicmodule:${DATACLAY_LOGICMODULE_DOCKER_TAG}
FROM python:3.7-alpine
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.opencontainers.image.title="dataClay client" \
      org.opencontainers.image.created=$BUILD_DATE \
      org.label-schema.vcs-ref=$VCS_REF \
      org.opencontainers.image.description="Active objects across the network" \
      org.opencontainers.image.url="https://dataclay.bsc.es/" \
      org.label-schema.vcs-url="https://github.com/bsc-dom/dataclay-packaging" \
      org.opencontainers.image.vendor="Barcelona Supercomputing Center (BSC-CNS)" \
      org.opencontainers.image.version=$VERSION \
      org.opencontainers.image.authors="support-dataclay@bsc.es" \
      org.opencontainers.image.licenses="BSD-3-Clause" \
      org.label-schema.docker.dockerfile="/docker/client/alpine.Dockerfile"

# Install packages:
RUN apk add --no-cache --update libstdc++
# Install java:
ENV JAVA_MINIMAL="/opt/java-minimal"
ENV PATH="$PATH:$JAVA_MINIMAL/bin"
COPY --from=1 "$JAVA_MINIMAL" "$JAVA_MINIMAL"
ENV JAVA_HOME=${JAVA_MINIMAL}
#RUN apk --no-cache --update add openjdk8-jre-base
RUN java -version

ENV DATACLAY_HOME=/home/dataclayusr/dataclay
ENV DATACLAY_JAR=${DATACLAY_HOME}/dataclay.jar
ENV DATACLAY_VIRTUAL_ENV=${DATACLAY_HOME}/dataclay_venv
ENV DATACLAY_LOG_CONFIG=${DATACLAY_HOME}/logging/log4j2.xml
WORKDIR ${DATACLAY_HOME}

# Copy from dspython
COPY --from=0 ${DATACLAY_HOME}/entrypoints/dataclay-python-entry-point ${DATACLAY_HOME}/entrypoints/dataclay-python-entry-point
COPY --from=0 ${DATACLAY_HOME}/dataclay_venv ${DATACLAY_VIRTUAL_ENV}
ENV PATH="${DATACLAY_VIRTUAL_ENV}/bin:${DATACLAY_HOME}/entrypoints:$PATH"

# check dataclay is installed 
RUN python --version
RUN python -c "import dataclay; print('import ok')"
RUN python -c "from grpc._cython import cygrpc as _cygrpc"

# Copy from dsjava
COPY --from=1 ${DATACLAY_JAR} ${DATACLAY_JAR}
COPY --from=1 ${DATACLAY_LOG_CONFIG} ${DATACLAY_LOG_CONFIG}
COPY --from=1 ${DATACLAY_HOME}/entrypoints/dataclay-java-entry-point ${DATACLAY_HOME}/entrypoints/dataclay-java-entry-point

# WARNING: Note that this script must be located among with dataclay pom.xml (see workdir)
ENV DATACLAYCMD=${DATACLAY_HOME}/entrypoints/dataclaycmd
COPY dataclaycmd.sh ${DATACLAYCMD}

# The command can contain additional options
ENTRYPOINT ["dataclaycmd"]

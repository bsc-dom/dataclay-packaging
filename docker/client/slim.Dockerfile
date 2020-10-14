ARG DATACLAY_DSPYTHON_DOCKER_TAG
ARG DATACLAY_LOGICMODULE_DOCKER_TAG
FROM bscdataclay/dspython:${DATACLAY_DSPYTHON_DOCKER_TAG}
FROM bscdataclay/logicmodule:${DATACLAY_LOGICMODULE_DOCKER_TAG}
FROM ubuntu:18.04
LABEL maintainer dataClay team <support-dataclay@bsc.es>
ARG DATACLAY_PYVER
ARG JDK

# Install packages:
RUN apt-get update \
        && apt-get install --no-install-recommends -y --allow-unauthenticated openjdk-${JDK}-jdk >/dev/null\
        python${DATACLAY_PYVER} python3-distutils \
        && rm -rf /var/lib/apt/lists/*

ENV DATACLAY_HOME=/home/dataclayusr/dataclay
ENV DATACLAY_JAR=${DATACLAY_HOME}/dataclay.jar

WORKDIR ${DATACLAY_HOME}

# Copy from dspython
COPY --from=0 ${DATACLAY_HOME}/entrypoints/dataclay-python-entry-point ${DATACLAY_HOME}/entrypoints/dataclay-python-entry-point
ENV DATACLAY_VIRTUAL_ENV=${DATACLAY_HOME}/dataclay_venv
COPY --from=0 ${DATACLAY_HOME}/dataclay_venv ${DATACLAY_VIRTUAL_ENV}

# Copy from dsjava
COPY --from=1 ${DATACLAY_JAR} ${DATACLAY_JAR}
COPY --from=1 ${DATACLAY_HOME}/entrypoints/dataclay-java-entry-point ${DATACLAY_HOME}/entrypoints/dataclay-java-entry-point
ENV CLASSPATH=${DATACLAY_JAR}:${CLASSPATH}

# Make sure we use the virtualenv and entrypoints:
ENV PATH="${DATACLAY_VIRTUAL_ENV}/bin:${DATACLAY_HOME}/entrypoints:$PATH"

# check dataclay is installed 
RUN echo ${DATACLAY_PYVER}
RUN python --version
RUN python -c "import dataclay; print('import ok')"

# WARNING: Note that this script must be located among with dataclay pom.xml (see workdir)
ENV DATACLAYCMD=${DATACLAY_HOME}/entrypoints/dataclaycmd
COPY dataclaycmd.sh ${DATACLAYCMD}

# The command can contain additional options
ENTRYPOINT ["dataclaycmd"]

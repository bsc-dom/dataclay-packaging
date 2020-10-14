ARG DATACLAY_DSPYTHON_DOCKER_TAG
ARG DATACLAY_LOGICMODULE_DOCKER_TAG
FROM bscdataclay/dspython:${DATACLAY_DSPYTHON_DOCKER_TAG}
FROM bscdataclay/logicmodule:${DATACLAY_LOGICMODULE_DOCKER_TAG}
FROM python:3.7-alpine

# Install packages:
RUN apk --no-cache --update add openjdk8 libstdc++

ENV DATACLAY_HOME=/home/dataclayusr/dataclay
ENV DATACLAY_JAR=${DATACLAY_HOME}/dataclay.jar
ENV DATACLAY_VIRTUAL_ENV=${DATACLAY_HOME}/dataclay_venv

WORKDIR ${DATACLAY_HOME}

# Copy from dspython
COPY --from=0 ${DATACLAY_HOME}/entrypoints/dataclay-python-entry-point ${DATACLAY_HOME}/entrypoints/dataclay-python-entry-point
COPY --from=0 ${DATACLAY_HOME}/dataclay_venv ${DATACLAY_VIRTUAL_ENV}
ENV PATH="${DATACLAY_VIRTUAL_ENV}/bin:${DATACLAY_HOME}/entrypoints:$PATH"

# check dataclay is installed 
RUN python --version
RUN python -c "import dataclay; print('import ok')"

# Copy from dsjava
COPY --from=1 ${DATACLAY_JAR} ${DATACLAY_JAR}
COPY --from=1 ${DATACLAY_HOME}/entrypoints/dataclay-java-entry-point ${DATACLAY_HOME}/entrypoints/dataclay-java-entry-point
ENV CLASSPATH=${DATACLAY_JAR}:${CLASSPATH}

# WARNING: Note that this script must be located among with dataclay pom.xml (see workdir)
ENV DATACLAYCMD=${DATACLAY_HOME}/entrypoints/dataclaycmd
COPY dataclaycmd.sh ${DATACLAYCMD}

# The command can contain additional options
ENTRYPOINT ["dataclaycmd"]

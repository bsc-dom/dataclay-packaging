ARG DATACLAY_DSPYTHON_DOCKER_TAG
ARG DATACLAY_LOGICMODULE_DOCKER_TAG
FROM bscdataclay/dspython:${DATACLAY_DSPYTHON_DOCKER_TAG}
FROM bscdataclay/logicmodule:${DATACLAY_LOGICMODULE_DOCKER_TAG}
LABEL maintainer dataClay team <support-dataclay@bsc.es>

COPY --from=0 /opt/venv /opt/venv
# Make sure we use the virtualenv:
ENV PATH="/opt/venv/bin:$PATH"

# Move to javaclay since dataclay client tool is there
WORKDIR /usr/src/dataclay/javaclay/
# Environment variables
# WARNING: Note that this script must be located among with dataclay pom.xml (see workdir)
ENV DATACLAYCMD=/usr/src/dataclay/dataclaycmd.sh
COPY dataclaycmd.sh ${DATACLAYCMD}

# The command can contain additional options
ENTRYPOINT ["bash", "/usr/src/dataclay/dataclaycmd.sh"]

ARG DATACLAY_DSPYTHON_DOCKER_TAG
ARG DATACLAY_LOGICMODULE_DOCKER_TAG
FROM bscdataclay/dspython:${DATACLAY_DSPYTHON_DOCKER_TAG}
#beginENVruntime
FROM bscdataclay/logicmodule:${DATACLAY_LOGICMODULE_DOCKER_TAG}
LABEL maintainer dataClay team <support-dataclay@bsc.es>


# Copy from dspython
COPY --from=0 ${DATACLAY_HOME}/pyextrae/dataclay_extrae_wrapper.so ${DATACLAY_HOME}/pyextrae/dataclay_extrae_wrapper.so
COPY --from=0 ${DATACLAY_HOME}/entrypoints/dataclay-python-entry-point ${DATACLAY_HOME}/entrypoints/dataclay-python-entry-point
COPY --from=0 /opt/venv /opt/venv

# Extrae env variables

ENV DATACLAY_EXTRAE_WRAPPER_LIB=${DATACLAY_HOME}/pyextrae/dataclay_extrae_wrapper.so
ENV PYEXTRAE_PATH=${EXTRAE_HOME}/libexec:${EXTRAE_HOME}/lib
ENV EXTRAE_CONFIG_FILE=${DATACLAY_HOME}/extrae/extrae_python.xml
ENV PYTHONPATH=${PYEXTRAE_PATH}:${PYTHONPATH}

# Make sure we use the virtualenv:
ENV PATH="/opt/venv/bin:$PATH"

# check pyextrae is installed
RUN python -c "import pyextrae.common.extrae as pyextrae_module; print('import ok')"
RUN python -c "from pyextrae.common.extrae import Extrae as extrae_dict_obj; print('import ok')"

# Move to javaclay since dataclay client tool is there
#COPY ./pom.xml ${DATACLAY_HOME}/client

# WARNING: Note that this script must be located among with dataclay pom.xml (see workdir)
ENV DATACLAYCMD=${DATACLAY_HOME}/entrypoints/dataclaycmd
COPY dataclaycmd.sh ${DATACLAYCMD}

# The command can contain additional options
ENTRYPOINT ["dataclaycmd"]
#endENVruntime

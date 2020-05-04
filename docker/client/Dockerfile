ARG DATACLAY_DSPYTHON_DOCKER_TAG
ARG DATACLAY_LOGICMODULE_DOCKER_TAG
FROM bscdataclay/dspython:${DATACLAY_DSPYTHON_DOCKER_TAG}
FROM bscdataclay/logicmodule:${DATACLAY_LOGICMODULE_DOCKER_TAG}
LABEL maintainer dataClay team <support-dataclay@bsc.es>

ARG DATACLAY_PYVER=3.7

# Copy from dspython
COPY --from=0 ${DATACLAY_HOME}/entrypoints/dataclay-python-entry-point ${DATACLAY_HOME}/entrypoints/dataclay-python-entry-point
COPY --from=0 ${DATACLAY_HOME}/pyclay ${DATACLAY_HOME}/pyclay
COPY --from=0 ${DATACLAY_VIRTUAL_ENV} ${DATACLAY_VIRTUAL_ENV}

RUN apt-get update \
       && apt-get install --no-install-recommends -y --allow-unauthenticated python${DATACLAY_PYVER} \
       && rm -rf /var/lib/apt/lists/*

# Extrae
ENV PYCLAY_EXTRAE_WRAPPER_LIB=${DATACLAY_HOME}/pyextrae/pyclay_extrae_wrapper.so
ENV PYEXTRAE_PATH=${EXTRAE_HOME}/libexec:${EXTRAE_HOME}/lib
ENV EXTRAE_CONFIG_FILE=${DATACLAY_HOME}/extrae/extrae_basic.xml
ENV PYTHONPATH=${PYEXTRAE_PATH}:${PYTHONPATH}
COPY --from=0 ${DATACLAY_HOME}/pyextrae/ ${DATACLAY_HOME}/pyextrae/
RUN cd ${DATACLAY_HOME}/pyextrae && gcc -L${EXTRAE_HOME}/lib -I${EXTRAE_HOME}/include extrae_wrapper.c -lpttrace --shared -o ${PYCLAY_EXTRAE_WRAPPER_LIB}


# Make sure we use the virtualenv:
ENV PATH="${DATACLAY_VIRTUAL_ENV}/bin:$PATH"

# check pyextrae is installed
RUN echo ${DATACLAY_PYVER}
RUN python --version
RUN python -c "import pyextrae.common.extrae as pyextrae_module; print('import ok')"
RUN python -c "from pyextrae.common.extrae import Extrae as extrae_dict_obj; print('import ok')"

# WARNING: Note that this script must be located among with dataclay pom.xml (see workdir)
ENV DATACLAYCMD=${DATACLAY_HOME}/entrypoints/dataclaycmd
COPY dataclaycmd.sh ${DATACLAYCMD}

# The command can contain additional options
ENTRYPOINT ["dataclaycmd"]

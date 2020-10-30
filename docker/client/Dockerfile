ARG DATACLAY_DSPYTHON_DOCKER_TAG
ARG DATACLAY_LOGICMODULE_DOCKER_TAG
FROM bscdataclay/dspython:${DATACLAY_DSPYTHON_DOCKER_TAG}
FROM bscdataclay/logicmodule:${DATACLAY_LOGICMODULE_DOCKER_TAG}
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
      org.label-schema.docker.dockerfile="/docker/client/Dockerfile"

ARG DATACLAY_PYVER=3.7

# Copy from dspython
COPY --from=0 ${DATACLAY_HOME}/entrypoints/dataclay-python-entry-point ${DATACLAY_HOME}/entrypoints/dataclay-python-entry-point
ENV DATACLAY_VIRTUAL_ENV=${DATACLAY_HOME}/dataclay_venv
COPY --from=0 ${DATACLAY_HOME}/dataclay_venv ${DATACLAY_VIRTUAL_ENV}

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
RUN python -c "import dataclay; print('import ok')"
RUN python -c "import pyextrae.common.extrae as pyextrae_module; print('import ok')"
RUN python -c "from pyextrae.common.extrae import Extrae as extrae_dict_obj; print('import ok')"

# WARNING: Note that this script must be located among with dataclay pom.xml (see workdir)
ENV DATACLAYCMD=${DATACLAY_HOME}/entrypoints/dataclaycmd
COPY dataclaycmd.sh ${DATACLAYCMD}

# The command can contain additional options
ENTRYPOINT ["dataclaycmd"]

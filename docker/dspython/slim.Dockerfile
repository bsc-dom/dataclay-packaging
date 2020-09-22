ARG BASE_VERSION
ARG REQUIREMENTS_TAG
FROM bscdataclay/dspython:${REQUIREMENTS_TAG}
FROM bscdataclay/base:${BASE_VERSION}
LABEL maintainer dataClay team <support-dataclay@bsc.es>

ARG DATACLAY_PYVER=3.7
ARG PYTHON_PIP_VERSION=3

# Install
RUN apt-get update \
       && apt-get install --no-install-recommends -y --allow-unauthenticated python${DATACLAY_PYVER} python${PYTHON_PIP_VERSION}-distutils \
       && rm -rf /var/lib/apt/lists/*

ENV DATACLAY_VIRTUAL_ENV=${DATACLAY_HOME}/dataclay_venv
COPY --from=0 ${DATACLAY_HOME}/dataclay_venv ${DATACLAY_VIRTUAL_ENV}
ENV PATH="$DATACLAY_VIRTUAL_ENV/bin:$PATH"
RUN python${DATACLAY_PYVER} --version

# Create source
RUN mkdir -p ${DATACLAY_HOME}/deploy/source
# =============== INSTALL DATACLAY =================== #

COPY ./pyclay/ ${DATACLAY_HOME}/pyclay/
# ignore requirements
RUN sed -i '/numpy*/d' ${DATACLAY_HOME}/pyclay/requirements.txt
RUN cd ${DATACLAY_HOME}/pyclay/ && python${DATACLAY_PYVER} setup.py install
RUN python -c "import dataclay; print('import ok')"

COPY ./health_check.sh ${DATACLAY_HOME}/health/health_check.sh
COPY ./extrae ${DATACLAY_HOME}/extrae

# Entrypoint
COPY ./dataclay-python-entry-point.sh ${DATACLAY_HOME}/entrypoints/dataclay-python-entry-point
# Modify path for entrypoints
ENV PATH=${DATACLAY_HOME}/entrypoints:${PATH}

ENV DEPLOY_PATH=${DATACLAY_HOME}/deploy

# Execute
# Don't use CMD in order to keep compatibility with singularity container's generator
ENTRYPOINT ["dataclay-python-entry-point","-m","dataclay.executionenv.server","--service"]

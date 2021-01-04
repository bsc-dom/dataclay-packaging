ARG BASE_VERSION
ARG REQUIREMENTS_TAG
# ============================================================ #
FROM bscdataclay/dspython:${REQUIREMENTS_TAG} as pyclay-installer
ENV DATACLAY_HOME=/home/dataclayusr/dataclay
ENV DATACLAY_VIRTUAL_ENV=${DATACLAY_HOME}/dataclay_venv
ENV PATH="$DATACLAY_VIRTUAL_ENV/bin:$PATH"
COPY ./pyclay/ /pyclay/
# remove numpy from requirements
RUN sed -i '/numpy*/d' /pyclay/requirements.txt
RUN cd /pyclay/ && python setup.py -q install
# ============================================================ #
FROM bscdataclay/base:${BASE_VERSION}
ARG VERSION
LABEL org.opencontainers.image.title="dataClay client" \
      org.opencontainers.image.description="Active objects across the network" \
      org.opencontainers.image.url="https://dataclay.bsc.es/" \
      org.label-schema.vcs-url="https://github.com/bsc-dom/dataclay-packaging" \
      org.opencontainers.image.vendor="Barcelona Supercomputing Center (BSC-CNS)" \
      org.opencontainers.image.version=$VERSION \
      org.opencontainers.image.authors="support-dataclay@bsc.es" \
      org.opencontainers.image.licenses="BSD-3-Clause" \
      org.label-schema.docker.dockerfile="/docker/dspython/slim.Dockerfile"

ARG DATACLAY_PYVER=3.7
ARG PYTHON_PIP_VERSION=3
# Install requiremenets
RUN apt-get update \
       && apt-get install --no-install-recommends -y --allow-unauthenticated python${DATACLAY_PYVER} python${PYTHON_PIP_VERSION}-distutils \
       && rm -rf /var/lib/apt/lists/*

# Install dataClay
ENV DATACLAY_VIRTUAL_ENV=${DATACLAY_HOME}/dataclay_venv
COPY --from=pyclay-installer ${DATACLAY_HOME}/dataclay_venv ${DATACLAY_VIRTUAL_ENV}
ENV PATH="$DATACLAY_VIRTUAL_ENV/bin:$PATH"

RUN python -c "import dataclay; print('import ok')"

# Create source
RUN mkdir -p ${DATACLAY_HOME}/deploy/source

COPY ./health_check.sh ${DATACLAY_HOME}/health/health_check.sh
COPY ./extrae ${DATACLAY_HOME}/extrae

# Entrypoint
COPY ./dataclay-python-entry-point.sh ${DATACLAY_HOME}/entrypoints/dataclay-python-entry-point
# Modify path for entrypoints
ENV PATH=${DATACLAY_HOME}/entrypoints:${PATH}

ENV DEPLOY_PATH=${DATACLAY_HOME}/deploy

# Execute
# Don't use CMD in order to keep compatibility with singularity container's generator
ENTRYPOINT ["dataclay-python-entry-point","-m","dataclay.executionenv.server"]

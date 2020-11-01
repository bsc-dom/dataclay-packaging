ARG DATACLAY_PYVER
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

FROM python:${DATACLAY_PYVER}-alpine
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
      org.label-schema.docker.dockerfile="/docker/dspython/alpine.Dockerfile"

# Working dir
ENV DATACLAY_HOME=/home/dataclayusr/dataclay
RUN mkdir -p ${DATACLAY_HOME}
WORKDIR ${DATACLAY_HOME}

# Create source
RUN mkdir -p ${DATACLAY_HOME}/deploy/source

# =============== INSTALL DATACLAY =================== #
RUN apk add libstdc++
ENV DATACLAY_VIRTUAL_ENV=${DATACLAY_HOME}/dataclay_venv
COPY --from=pyclay-installer ${DATACLAY_HOME}/dataclay_venv ${DATACLAY_VIRTUAL_ENV}
ENV PATH="$DATACLAY_VIRTUAL_ENV/bin:$PATH"
RUN python -c "import dataclay; print('import ok')"

COPY ./health_check.sh ${DATACLAY_HOME}/health/health_check.sh

# Entrypoint
COPY ./dataclay-python-entry-point.sh ${DATACLAY_HOME}/entrypoints/dataclay-python-entry-point
# Modify path for entrypoints
ENV PATH=${DATACLAY_HOME}/entrypoints:${PATH}
ENV DEPLOY_PATH=${DATACLAY_HOME}/deploy

# Execute
# Don't use CMD in order to keep compatibility with singularity container's generator
ENTRYPOINT ["dataclay-python-entry-point","-m","dataclay.executionenv.server"]

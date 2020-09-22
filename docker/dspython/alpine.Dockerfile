ARG DATACLAY_PYVER
ARG REQUIREMENTS_TAG
FROM bscdataclay/dspython:${REQUIREMENTS_TAG}
FROM python:${DATACLAY_PYVER}-alpine
LABEL maintainer dataClay team <support-dataclay@bsc.es>

RUN apk add libstdc++

# Working dir 
ENV DATACLAY_HOME=/home/dataclayusr/dataclay
RUN mkdir -p ${DATACLAY_HOME}
WORKDIR ${DATACLAY_HOME}

# Create source
RUN mkdir -p ${DATACLAY_HOME}/deploy/source

# =============== INSTALL DATACLAY =================== #
ENV DATACLAY_VIRTUAL_ENV=${DATACLAY_HOME}/dataclay_venv
COPY --from=0 ${DATACLAY_HOME}/dataclay_venv ${DATACLAY_VIRTUAL_ENV}
ENV PATH="$DATACLAY_VIRTUAL_ENV/bin:$PATH"

COPY ./pyclay/ ${DATACLAY_HOME}/pyclay/
# remove numpy from requirements
RUN sed -i '/numpy*/d' ${DATACLAY_HOME}/pyclay/requirements.txt
RUN cd ${DATACLAY_HOME}/pyclay/ && python setup.py install
RUN python -c "import dataclay; print('import ok')"

COPY ./health_check.sh ${DATACLAY_HOME}/health/health_check.sh

# Entrypoint
COPY ./dataclay-python-entry-point.sh ${DATACLAY_HOME}/entrypoints/dataclay-python-entry-point
# Modify path for entrypoints
ENV PATH=${DATACLAY_HOME}/entrypoints:${PATH}
ENV DEPLOY_PATH=${DATACLAY_HOME}/deploy

# Execute
# Don't use CMD in order to keep compatibility with singularity container's generator
ENTRYPOINT ["dataclay-python-entry-point","-m","dataclay.executionenv.server","--service"]

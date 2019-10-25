ARG DATACLAY_JAVA_DOCKER_TAG
FROM bscdataclay/dsjava:${DATACLAY_JAVA_DOCKER_TAG}
LABEL maintainer dataClay team <support-dataclay@bsc.es>

# Python EE extends dsjava to have Extrae installed + some configuration files
ARG DATACLAY_PYVER=3
ARG PYTHON_PIP_VERSION=3

# ============ PRE-INSTALLATION ================== #

# Install extrae requirements
RUN apt-get update \
       && apt-get install --no-install-recommends -y --allow-unauthenticated python${DATACLAY_PYVER} python${DATACLAY_PYVER}-dev python${PYTHON_PIP_VERSION}-pip \
       && rm -rf /var/lib/apt/lists/*

# Set virtual environment since we could inherit some other python installations
ENV VIRTUAL_ENV=/opt/venv
RUN pip${PYTHON_PIP_VERSION} install virtualenv
RUN python${DATACLAY_PYVER} -m virtualenv --python=/usr/bin/python${DATACLAY_PYVER} ${VIRTUAL_ENV}
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN python --version


# Create source
RUN mkdir -p /usr/src/dataclay/deploy/source

# =============== INSTALL DATACLAY REQUIREMENTS =================== #

COPY requirements.txt requirements.txt
RUN pip${PYTHON_PIP_VERSION} install -r requirements.txt

# =================== EXTRAE ENVIRONMENT VARIABLES ======================== #

ENV DATACLAY_EXTRAE_WRAPPER_LIB=/usr/src/dataclay/pyextrae/dataclay_extrae_wrapper.so
ENV PYEXTRAE_PATH=$EXTRAE_HOME/libexec:$EXTRAE_HOME/lib
ENV PYTHONPATH=$PYEXTRAE_PATH:$PYTHONPATH

# =============== INSTALL DATACLAY =================== #

RUN mkdir src
COPY ./docker-health/ docker-health
COPY ./src/dataclay src/dataclay
COPY ./src/storage src/storage
COPY ./setup.py setup.py
RUN python setup.py install
RUN rm -rf src

# Execute
# Don't use CMD in order to keep compatibility with singularity container's generator
ENTRYPOINT ["python","-m","dataclay.executionenv.server"]

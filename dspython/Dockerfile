ARG BASE_VERSION
FROM bscdataclay/base:${BASE_VERSION}
LABEL maintainer dataClay team <support-dataclay@bsc.es>

ARG DATACLAY_PYVER=3.6
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
WORKDIR /usr/src/dataclay/pyclay/
RUN mkdir -p /usr/src/dataclay/pyclay/deploy/source

# =============== INSTALL DATACLAY REQUIREMENTS =================== #

COPY ./pyclay/requirements.txt requirements.txt
RUN pip${PYTHON_PIP_VERSION} install -r requirements.txt

# =================== EXTRAE ENVIRONMENT VARIABLES ======================== #

ENV DATACLAY_EXTRAE_WRAPPER_LIB=/usr/src/dataclay/pyclay/pyextrae/dataclay_extrae_wrapper.so
ENV PYEXTRAE_PATH=$EXTRAE_HOME/libexec:$EXTRAE_HOME/lib
ENV PYTHONPATH=$PYEXTRAE_PATH:$PYTHONPATH

# Compile wrapper lib 
COPY ./pyextrae pyextrae
RUN cd pyextrae && gcc -L${EXTRAE_HOME}/lib -I${EXTRAE_HOME}/include extrae_wrapper.c -lpttrace --shared -o ${DATACLAY_EXTRAE_WRAPPER_LIB}

# =============== INSTALL DATACLAY =================== #
COPY ./health_check.sh health_check.sh
COPY ./pyclay/ /usr/src/dataclay/pyclay/
RUN python setup.py install

# Execute
# Don't use CMD in order to keep compatibility with singularity container's generator
ENTRYPOINT ["python","-m","dataclay.executionenv.server"]

ARG BASE_VERSION
FROM bscdataclay/base:${BASE_VERSION}
LABEL maintainer dataClay team <support-dataclay@bsc.es>

ARG DATACLAY_PYVER=3.6
ARG PYTHON_PIP_VERSION=3

# ============ REQUIREMENTS ================== #

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
ENV EXTRAE_CONFIG_FILE=/usr/src/dataclay/extrae/extrae_python.xml
ENV PYTHONPATH=$PYEXTRAE_PATH:$PYTHONPATH

# =================== EXTRAE wrapper ======================== #

# Compile wrapper lib 
COPY ./pyextrae pyextrae
RUN cd pyextrae && gcc -L${EXTRAE_HOME}/lib -I${EXTRAE_HOME}/include extrae_wrapper.c -lpttrace --shared -o ${DATACLAY_EXTRAE_WRAPPER_LIB}
# check pyextrae is installed
RUN python -c "import pyextrae.common.extrae as pyextrae_module; print('import ok')"
RUN python -c "from pyextrae.common.extrae import Extrae as extrae_dict_obj; print('import ok')"
RUN python -c "from ctypes import cdll; cdll.LoadLibrary(\"/usr/src/dataclay/pyclay/pyextrae/dataclay_extrae_wrapper.so\")"
# =============== INSTALL DATACLAY =================== #
ENV DEPLOY_PATH=/usr/src/dataclay/pyclay/deploy
COPY ./pyclay/ /usr/src/dataclay/pyclay/
RUN python setup.py install

COPY ./health_check.sh /usr/src/dataclay/pyclay/health_check.sh
COPY ./python-entry-point.sh /usr/src/dataclay/pyclay/python-entry-point.sh

# Execute
# Don't use CMD in order to keep compatibility with singularity container's generator
ENTRYPOINT ["/usr/src/dataclay/pyclay/python-entry-point.sh","-m","dataclay.executionenv.server"]

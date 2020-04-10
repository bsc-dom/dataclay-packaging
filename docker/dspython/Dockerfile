ARG BASE_VERSION
FROM bscdataclay/base:${BASE_VERSION}
LABEL maintainer dataClay team <support-dataclay@bsc.es>

ARG DATACLAY_PYVER=3.7
ARG PYTHON_PIP_VERSION=3

# ============ REQUIREMENTS ================== #

# Install extrae requirements
RUN apt-get update \
       && apt-get install --no-install-recommends -y --allow-unauthenticated python${DATACLAY_PYVER} \
       python${DATACLAY_PYVER}-dev python${PYTHON_PIP_VERSION}-pip \
       python${PYTHON_PIP_VERSION}-setuptools \
       libatlas3-base libgfortran5 >/dev/null \
       && rm -rf /var/lib/apt/lists/*

# Set virtual environment since we could inherit some other python installations
RUN pip${PYTHON_PIP_VERSION} install wheel 
RUN pip${PYTHON_PIP_VERSION} install virtualenv
RUN python${PYTHON_PIP_VERSION} -m virtualenv --python=/usr/bin/python${DATACLAY_PYVER} ${VIRTUAL_ENV}
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN python --version

# Create source
RUN mkdir -p ${DATACLAY_HOME}/deploy/source

# =============== INSTALL DATACLAY REQUIREMENTS =================== #

COPY ./pyclay/requirements.txt requirements.txt
RUN pip${PYTHON_PIP_VERSION} install -r requirements.txt --extra-index-url=https://www.piwheels.org/simple  --extra-index-url=https://www.piwheels.hostedpi.com/simple
# =================== EXTRAE ENVIRONMENT VARIABLES ======================== #

ENV DATACLAY_EXTRAE_WRAPPER_LIB=${DATACLAY_HOME}/pyextrae/dataclay_extrae_wrapper.so
ENV PYEXTRAE_PATH=${EXTRAE_HOME}/libexec:${EXTRAE_HOME}/lib
ENV EXTRAE_CONFIG_FILE=${DATACLAY_HOME}/extrae/extrae_python.xml
ENV PYTHONPATH=${PYEXTRAE_PATH}:${PYTHONPATH}

# =================== EXTRAE wrapper ======================== #

# Compile wrapper lib 
COPY ./pyextrae pyextrae
RUN cd pyextrae && gcc -L${EXTRAE_HOME}/lib -I${EXTRAE_HOME}/include extrae_wrapper.c -lpttrace --shared -o ${DATACLAY_EXTRAE_WRAPPER_LIB}
# check pyextrae is installed
RUN python -c "import pyextrae.common.extrae as pyextrae_module; print('import ok')"
RUN python -c "from pyextrae.common.extrae import Extrae as extrae_dict_obj; print('import ok')"
RUN python -c "from ctypes import cdll; cdll.LoadLibrary(\"${DATACLAY_HOME}/pyextrae/dataclay_extrae_wrapper.so\")"
# =============== INSTALL DATACLAY =================== #
COPY ./pyclay/ ${DATACLAY_HOME}
RUN python setup.py install

COPY ./health_check.sh ${DATACLAY_HOME}/health/health_check.sh

# Entrypoint
COPY ./dataclay-python-entry-point.sh ${DATACLAY_HOME}/entrypoints/dataclay-python-entry-point
# Modify path for entrypoints
ENV PATH=${DATACLAY_HOME}/entrypoints:${PATH}

ENV DEPLOY_PATH=${DATACLAY_HOME}/deploy

# Execute
# Don't use CMD in order to keep compatibility with singularity container's generator
ENTRYPOINT ["dataclay-python-entry-point","-m","dataclay.executionenv.server"]

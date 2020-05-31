ARG BASE_VERSION
ARG REQUIREMENTS_TAG
FROM bscdataclay/dspython:${REQUIREMENTS_TAG}
FROM bscdataclay/base:${BASE_VERSION}
LABEL maintainer dataClay team <support-dataclay@bsc.es>

ARG DATACLAY_PYVER=3.7
ARG PYTHON_PIP_VERSION=3

# Install
RUN apt-get update \
       && apt-get install --no-install-recommends -y --allow-unauthenticated python${DATACLAY_PYVER} \
       python${DATACLAY_PYVER}-dev python${PYTHON_PIP_VERSION}-pip \
       python${PYTHON_PIP_VERSION}-setuptools \
       && rm -rf /var/lib/apt/lists/*

ENV DATACLAY_VIRTUAL_ENV=${DATACLAY_HOME}/dataclay_venv
COPY --from=0 ${DATACLAY_HOME}/dataclay_venv ${DATACLAY_VIRTUAL_ENV}
ENV PATH="$DATACLAY_VIRTUAL_ENV/bin:$PATH"
RUN python${DATACLAY_PYVER} --version

# Create source
RUN mkdir -p ${DATACLAY_HOME}/deploy/source

# =================== EXTRAE ENVIRONMENT VARIABLES ======================== #

ENV PYCLAY_EXTRAE_WRAPPER_LIB=${DATACLAY_HOME}/pyextrae/pyclay_extrae_wrapper.so
ENV PYEXTRAE_PATH=${EXTRAE_HOME}/libexec:${EXTRAE_HOME}/lib
ENV EXTRAE_CONFIG_FILE=${DATACLAY_HOME}/extrae/extrae_python.xml
ENV PYTHONPATH=${PYEXTRAE_PATH}:${DATACLAY_VIRTUAL_ENV}/lib/python${DATACLAY_PYVER}/site-packages:${PYTHONPATH}

# =================== EXTRAE wrapper ======================== #

# Get wrapper lib 
COPY ./pyextrae pyextrae
RUN cd pyextrae && gcc -fPIC -L${EXTRAE_HOME}/lib -I${EXTRAE_HOME}/include extrae_wrapper.c -lpttrace --shared -o ${PYCLAY_EXTRAE_WRAPPER_LIB}
# check pyextrae is installed
RUN python -c "import pyextrae.common.extrae as pyextrae_module; print('import ok')"
RUN python -c "from pyextrae.common.extrae import Extrae as extrae_dict_obj; print('import ok')"
RUN python -c "from ctypes import cdll; cdll.LoadLibrary(\"${DATACLAY_HOME}/pyextrae/pyclay_extrae_wrapper.so\")"
# =============== INSTALL DATACLAY =================== #

COPY ./pyclay/ ${DATACLAY_HOME}/pyclay/
RUN cd ${DATACLAY_HOME}/pyclay/ && python${DATACLAY_PYVER} setup.py install

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

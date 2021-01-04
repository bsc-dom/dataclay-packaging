FROM ubuntu:18.04
LABEL org.opencontainers.image.title="dataClay python requirements image" \
      org.opencontainers.image.description="Active objects across the network" \
      org.opencontainers.image.url="https://dataclay.bsc.es/" \
      org.label-schema.vcs-url="https://github.com/bsc-dom/dataclay-packaging" \
      org.opencontainers.image.vendor="Barcelona Supercomputing Center (BSC-CNS)" \
      org.opencontainers.image.authors="support-dataclay@bsc.es" \
      org.opencontainers.image.licenses="BSD-3-Clause" \
      org.label-schema.docker.dockerfile="/docker/dspython/requirements/Dockerfile"

ARG DATACLAY_PYVER=3.7
ARG PYTHON_PIP_VERSION=3

# ============ REQUIREMENTS ================== #

# Install
RUN apt-get update \
       && apt-get install --no-install-recommends -y --allow-unauthenticated python${DATACLAY_PYVER} \
       gcc libyaml-dev libpython${DATACLAY_PYVER}-dev build-essential curl libpython2.7-dev \
       python${DATACLAY_PYVER}-dev python${PYTHON_PIP_VERSION}-pip \
       python${PYTHON_PIP_VERSION}-setuptools \
       libatlas3-base libgfortran5 >/dev/null \
       && rm -rf /var/lib/apt/lists/*

# Set virtual environment since we could inherit some other python installations
ENV DATACLAY_HOME=/home/dataclayusr/dataclay
RUN mkdir -p ${DATACLAY_HOME}
ENV DATACLAY_VIRTUAL_ENV=${DATACLAY_HOME}/dataclay_venv
RUN pip${PYTHON_PIP_VERSION} install --upgrade pip
RUN pip${PYTHON_PIP_VERSION} install wheel 
RUN pip${PYTHON_PIP_VERSION} install virtualenv
RUN python${PYTHON_PIP_VERSION} -m virtualenv --python=/usr/bin/python${DATACLAY_PYVER} ${DATACLAY_VIRTUAL_ENV}

# =============== INSTALL DATACLAY REQUIREMENTS =================== #

ENV PATH="$DATACLAY_VIRTUAL_ENV/bin:$PATH"
COPY ./requirements.txt requirements.txt
RUN python${DATACLAY_PYVER} -m pip install --upgrade pip
RUN python${DATACLAY_PYVER} -m pip install -r requirements.txt
RUN python${DATACLAY_PYVER} -c "from grpc._cython import cygrpc as _cygrpc"

ENTRYPOINT ["Nothing to do here"]

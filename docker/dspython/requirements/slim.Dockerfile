FROM ubuntu:18.04
LABEL maintainer dataClay team <support-dataclay@bsc.es>

ARG DATACLAY_PYVER=3.7
ARG PYTHON_PIP_VERSION=3

# Install
RUN apt-get update \
       && apt-get install --no-install-recommends -y --allow-unauthenticated python${DATACLAY_PYVER} \
       python${PYTHON_PIP_VERSION}-pip >/dev/null \
       && rm -rf /var/lib/apt/lists/*

# ============ REQUIREMENTS ================== #

# Set virtual environment since we could inherit some other python installations
# Working dir 
ENV DATACLAY_HOME=/home/dataclayusr/dataclay
RUN mkdir -p ${DATACLAY_HOME}
ENV DATACLAY_VIRTUAL_ENV=${DATACLAY_HOME}/dataclay_venv
RUN pip${PYTHON_PIP_VERSION} install --upgrade pip
RUN pip${PYTHON_PIP_VERSION} install wheel 
RUN pip${PYTHON_PIP_VERSION} install virtualenv
RUN python${PYTHON_PIP_VERSION} -m virtualenv --python=/usr/bin/python${DATACLAY_PYVER} ${DATACLAY_VIRTUAL_ENV}

# =============== INSTALL DATACLAY REQUIREMENTS =================== #

ENV PATH="$DATACLAY_VIRTUAL_ENV/bin:$PATH"
COPY ./slim.requirements.txt requirements.txt
RUN python${DATACLAY_PYVER} -m pip install --upgrade pip


# Install
RUN apt-get update \
       && apt-get install --no-install-recommends -y --allow-unauthenticated \
       build-essential python${DATACLAY_PYVER}-dev >/dev/null \
       && python${DATACLAY_PYVER} -m pip install -r requirements.txt --extra-index-url=https://www.piwheels.org/simple \
       && apt-get purge -y build-essential python${DATACLAY_PYVER}-dev \
       python${DATACLAY_PYVER}-dev >/dev/null \
       && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["Nothing to do here"]

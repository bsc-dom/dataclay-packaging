ARG DATACLAY_PYVER=3.7
FROM python:${DATACLAY_PYVER}-alpine
LABEL org.opencontainers.image.title="dataClay python requirements image" \
      org.opencontainers.image.description="Active objects across the network" \
      org.opencontainers.image.url="https://dataclay.bsc.es/" \
      org.label-schema.vcs-url="https://github.com/bsc-dom/dataclay-packaging" \
      org.opencontainers.image.vendor="Barcelona Supercomputing Center (BSC-CNS)" \
      org.opencontainers.image.authors="support-dataclay@bsc.es" \
      org.opencontainers.image.licenses="BSD-3-Clause" \
      org.label-schema.docker.dockerfile="/docker/dspython/requirements/alpine.Dockerfile"

ENV DATACLAY_HOME=/home/dataclayusr/dataclay
ENV PIP_TIMEOUT=300
RUN mkdir -p ${DATACLAY_HOME}
ENV DATACLAY_VIRTUAL_ENV=${DATACLAY_HOME}/dataclay_venv
RUN python -m pip install --default-timeout=$PIP_TIMEOUT --upgrade pip
RUN python -m pip install --default-timeout=$PIP_TIMEOUT wheel 
RUN python -m pip install --default-timeout=$PIP_TIMEOUT virtualenv
RUN python -m virtualenv ${DATACLAY_VIRTUAL_ENV}

# =============== INSTALL DATACLAY REQUIREMENTS =================== #

ENV PATH="$DATACLAY_VIRTUAL_ENV/bin:$PATH"
COPY ./alpine.requirements.txt requirements.txt
RUN python -m pip install --default-timeout=$PIP_TIMEOUT --upgrade pip
RUN apk add --update --no-cache build-base linux-headers \
	&& python -m pip install --default-timeout=$PIP_TIMEOUT -r requirements.txt \
	&& apk del build-base linux-headers && \
    rm -rf /var/cache/apk/*
RUN apk add libstdc++

ENTRYPOINT ["Nothing to do here"]

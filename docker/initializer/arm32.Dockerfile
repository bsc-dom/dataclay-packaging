ARG CLIENT_TAG
ARG REGISTRY=""
FROM ${REGISTRY}bscdataclay/client:${CLIENT_TAG}
ARG BUILD_DATE
ARG VCS_REF
LABEL org.opencontainers.image.title="dataClay initializer image" \
      org.opencontainers.image.created=$BUILD_DATE \
      org.label-schema.vcs-ref=$VCS_REF \
      org.opencontainers.image.description="Active objects across the network" \
      org.opencontainers.image.url="https://dataclay.bsc.es/" \
      org.label-schema.vcs-url="https://github.com/bsc-dom/dataclay-packaging" \
      org.opencontainers.image.vendor="Barcelona Supercomputing Center (BSC-CNS)" \
      org.opencontainers.image.authors="support-dataclay@bsc.es" \
      org.opencontainers.image.licenses="BSD-3-Clause" \
      org.label-schema.docker.dockerfile="/docker/initializer/Dockerfile"

ARG DEFAULT_DATASET=defaultDS
ARG DEFAULT_USER=defaultUser
ARG DEFAULT_PASS=defaultPass
ARG CACHEBUST=1
ARG WORKING_DIR=/dataclay-initializer
ARG DC_SHARED_VOLUME=/srv/dataclay/shared
ARG LOGICMODULE_PORT_TCP
ARG LOGICMODULE_HOST
ARG JAVA_NAMESPACES
ARG PYTHON_NAMESPACES
ARG JAVA_MODELS_PATH
ARG PYTHON_MODELS_PATH
ARG IMPORT_MODELS_FROM_EXTERNAL_DC_HOSTS
ARG IMPORT_MODELS_FROM_EXTERNAL_DC_PORTS
ARG IMPORT_MODELS_FROM_EXTERNAL_DC_NAMESPACES

WORKDIR ${WORKING_DIR}

# Copy files
COPY initialize-dataclay.sh .
COPY health_check.sh .

ENV DATACLAYCLIENTCONFIG=${WORKING_DIR}/client.properties  \
    DATASET=${DEFAULT_DATASET}  \
    USER=${DEFAULT_USER}  \
    PASS=${DEFAULT_PASS}  \
    DC_SHARED_VOLUME=${DC_SHARED_VOLUME} \
    LOGICMODULE_HOST=${LOGICMODULE_HOST} \
    LOGICMODULE_PORT_TCP=${LOGICMODULE_PORT_TCP} \
    JAVA_MODELS_PATH=${JAVA_MODELS_PATH} \
    PYTHON_MODELS_PATH=${PYTHON_MODELS_PATH} \
    JAVA_NAMESPACES=${JAVA_NAMESPACES} \
    PYTHON_NAMESPACES=${PYTHON_NAMESPACES} \
    IMPORT_MODELS_FROM_EXTERNAL_DC_HOSTS=${IMPORT_MODELS_FROM_EXTERNAL_DC_HOSTS} \
    IMPORT_MODELS_FROM_EXTERNAL_DC_PORTS=${IMPORT_MODELS_FROM_EXTERNAL_DC_PORTS} \
    IMPORT_MODELS_FROM_EXTERNAL_DC_NAMESPACES=${IMPORT_MODELS_FROM_EXTERNAL_DC_NAMESPACES}

VOLUME ${DC_SHARED_VOLUME}

ENTRYPOINT ["sh","-x","./initialize-dataclay.sh"]
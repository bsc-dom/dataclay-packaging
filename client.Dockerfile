ARG DATACLAY_PYCLAY_DOCKER_TAG
FROM bscdataclay/dspython:${DATACLAY_PYCLAY_DOCKER_TAG}
LABEL maintainer dataClay team <support-dataclay@bsc.es>
# Since python ds extends java ds we have Java installed and all needed libraries. 

# Environment variables
ENV DATACLAYCMD=/usr/src/dataclay/scripts/client/dataclaycmd.sh

# The command can contain additional options
ENTRYPOINT ["bash", "/usr/src/dataclay/scripts/client/dataclaycmd.sh"]

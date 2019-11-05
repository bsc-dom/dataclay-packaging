ARG DATACLAY_PYCLAY_DOCKER_TAG
FROM bscdataclay/dspython:${DATACLAY_PYCLAY_DOCKER_TAG}
LABEL maintainer dataClay team <support-dataclay@bsc.es>
# Since python ds extends java ds we have Java installed and all needed libraries. 

WORKDIR /usr/src/dataclay/javaclay/

# Environment variables
# WARNING: Note that this script must be located among with dataclay pom.xml (see workdir)
COPY dataclaycmd.sh /usr/src/dataclay/dataclaycmd.sh

# The command can contain additional options
ENTRYPOINT ["bash", "/usr/src/dataclay/dataclaycmd.sh"]

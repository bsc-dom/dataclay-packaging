ARG LOGICMODULE_VERSION
FROM bscdataclay/logicmodule:${LOGICMODULE_VERSION}
LABEL maintainer dataClay team <support-dataclay@bsc.es>

# Healthcheck
COPY ./health_check.sh /usr/src/dataclay/health_check.sh

# ================= SERVICE ==================== #
ENTRYPOINT ["/usr/src/dataclay/mvn-entry-point.sh", "-Dexec.mainClass=es.bsc.dataclay.dataservice.server.DataServiceSrv"] 

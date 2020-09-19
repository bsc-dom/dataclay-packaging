ARG LOGICMODULE_VERSION
FROM bscdataclay/logicmodule:${LOGICMODULE_VERSION}
LABEL maintainer dataClay team <support-dataclay@bsc.es>

# Healthcheck
COPY ./health_check.sh ${DATACLAY_HOME}/health/health_check.sh

# ================= SERVICE ==================== #
ENTRYPOINT ["dataclay-java-entry-point", "es.bsc.dataclay.dataservice.server.DataServiceSrv","--service"] 

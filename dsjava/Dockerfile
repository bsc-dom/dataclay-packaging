ARG LOGICMODULE_VERSION
FROM bscdataclay/logicmodule:${LOGICMODULE_VERSION}
LABEL maintainer dataClay team <support-dataclay@bsc.es>

# Healthcheck
COPY ./health_check.sh health_check.sh

# ================= SERVICE ==================== #
ENTRYPOINT ["mvn", "exec:exec", "-Dlog4j.configurationFile=$LOG4J_CLASSPATH", "-Dexec.mainClass=es.bsc.dataclay.dataservice.server.DataServiceSrv"] 

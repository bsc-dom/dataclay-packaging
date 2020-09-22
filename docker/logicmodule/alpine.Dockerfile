ARG BASE_VERSION
FROM openjdk:8u212-jre-alpine
LABEL maintainer dataClay team <support-dataclay@bsc.es>

ARG LOCAL_JAR="*-jar-with-dependencies.jar"
ARG JDK=11

# Working dir 
ENV DATACLAY_HOME=/home/dataclayusr/dataclay
RUN mkdir -p ${DATACLAY_HOME}
WORKDIR ${DATACLAY_HOME}

# Configure dataclay environment variables
ENV DATACLAY_LOG_CONFIG=${DATACLAY_HOME}/logging/log4j2.xml
ENV DATACLAY_JAR=${DATACLAY_HOME}/dataclay.jar

# Get dataClay JAR 
COPY ./javaclay/target/${LOCAL_JAR} ${DATACLAY_JAR}
ENV CLASSPATH=${DATACLAY_JAR}:${CLASSPATH}

# Copy entrypoint
COPY ./dataclay-java-entry-point.sh ${DATACLAY_HOME}/entrypoints/dataclay-java-entry-point

# Modify path for entrypoints
ENV PATH=${DATACLAY_HOME}/entrypoints:${PATH}

# Copy healthcheck
COPY ./health_check.sh ${DATACLAY_HOME}/health/health_check.sh

# Copy configurations and dynamic files (more likely to be changed)
COPY ./javaclay/dataclay-common/cfglog/log4j2.xml ${DATACLAY_LOG_CONFIG}

# ================= SERVICE ==================== #
ENTRYPOINT ["dataclay-java-entry-point", "es.bsc.dataclay.logic.server.LogicModuleSrv","--service"] 

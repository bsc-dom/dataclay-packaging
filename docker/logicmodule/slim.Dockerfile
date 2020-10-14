ARG BASE_VERSION
FROM bscdataclay/base:${BASE_VERSION}
LABEL maintainer dataClay team <support-dataclay@bsc.es>

ARG LOCAL_JAR
ARG JDK=11

# Install javaclay packages:
RUN apt-get update \
        && apt-get install --no-install-recommends -y --allow-unauthenticated openjdk-${JDK}-jre-headless >/dev/null\
        && rm -rf /var/lib/apt/lists/*
       
# Set Java home. We create a symbolic link to be arch-independant 
RUN ln -s /usr/lib/jvm/java-${JDK}-openjdk* /usr/lib/jvm/java-default
ENV JAVA_HOME=/usr/lib/jvm/java-default
RUN update-alternatives --install "/usr/bin/java" "java" ${JAVA_HOME}/bin/java 99999 && \
	update-alternatives --set java ${JAVA_HOME}/bin/java

# Configure dataclay environment variables
ENV DATACLAY_LOG_CONFIG=${DATACLAY_HOME}/logging/log4j2.xml
ENV DATACLAY_JAR=${DATACLAY_HOME}/dataclay.jar

# Get dataClay JAR 
COPY ${LOCAL_JAR} ${DATACLAY_JAR}
ENV CLASSPATH=${DATACLAY_JAR}:${CLASSPATH}

# Copy entrypoint
COPY ./dataclay-java-entry-point.sh ${DATACLAY_HOME}/entrypoints/dataclay-java-entry-point
#COPY ./dataclay-mvn-entry-point.sh ${DATACLAY_HOME}/entrypoints/dataclay-mvn-entry-point

# Modify path for entrypoints
ENV PATH=${DATACLAY_HOME}/entrypoints:${PATH}

# Copy healthcheck
COPY ./health_check.sh ${DATACLAY_HOME}/health/health_check.sh
COPY ./prepare_to_export.sh /prepare_to_export.sh

# Copy configurations and dynamic files (more likely to be changed)
COPY ./javaclay/dataclay-common/cfglog/log4j2.xml ${DATACLAY_LOG_CONFIG}

# ================= SERVICE ==================== #
ENTRYPOINT ["dataclay-java-entry-point", "es.bsc.dataclay.logic.server.LogicModuleSrv","--service"] 

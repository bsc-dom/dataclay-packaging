ARG BASE_VERSION
FROM bscdataclay/base:${BASE_VERSION}
LABEL maintainer dataClay team <support-dataclay@bsc.es>

ARG LOCAL_JAR
ARG JDK=11

# Install javaclay packages:
RUN apt-get update \
        && apt-get install --no-install-recommends -y --allow-unauthenticated openjdk-${JDK}-jdk >/dev/null\
        && rm -rf /var/lib/apt/lists/*
       
# Set Java home. We create a symbolic link to be arch-independant 
RUN ln -s /usr/lib/jvm/java-${JDK}-openjdk* /usr/lib/jvm/java-default
ENV JAVA_HOME=/usr/lib/jvm/java-default
RUN update-alternatives --install "/usr/bin/java" "java" ${JAVA_HOME}/bin/java 99999 && \
	update-alternatives --install "/usr/bin/javac" "javac" ${JAVA_HOME}/bin/javac 99999 && \
	update-alternatives --set java ${JAVA_HOME}/bin/java && \
	update-alternatives --set javac ${JAVA_HOME}/bin/javac

# Configure dataclay environment variables
ENV DATACLAY_LOG_CONFIG=${DATACLAY_HOME}/logging/log4j2.xml
ENV DATACLAY_JAR=${DATACLAY_HOME}/dataclay.jar

# Get dataClay JAR 
COPY ${LOCAL_JAR} ${DATACLAY_JAR}
ENV CLASSPATH=${DATACLAY_JAR}:${CLASSPATH}

# Copy entrypoint
COPY ./dataclay-java-entry-point.sh ${DATACLAY_HOME}/entrypoints/dataclay-java-entry-point
COPY ./dataclay-mvn-entry-point.sh ${DATACLAY_HOME}/entrypoints/dataclay-mvn-entry-point

# Modify path for entrypoints
ENV PATH=${DATACLAY_HOME}/entrypoints:${PATH}

# Extrae wrapper 
ENV JAVACLAY_EXTRAE_WRAPPER_LIB=${DATACLAY_HOME}/javaextrae/javaclay_extrae_wrapper.so
COPY ./javaextrae javaextrae
RUN cd javaextrae &&\
		gcc -fPIC \
	   -I${JAVA_HOME}/include \
	   -I${JAVA_HOME}/include/linux \
	   -I${EXTRAE_HOME}/include \
	   -I${DATACLAY_HOME}/javaextrae \
	   es_bsc_dataclay_extrae_Wrapper.c \
	   --shared \
	   -o ${JAVACLAY_EXTRAE_WRAPPER_LIB}

# Copy healthcheck
COPY ./health_check.sh ${DATACLAY_HOME}/health/health_check.sh
COPY ./extrae ${DATACLAY_HOME}/extrae
COPY ./prepare_to_export.sh /prepare_to_export.sh

# Copy configurations and dynamic files (more likely to be changed)
COPY ./javaclay/dataclay-common/cfglog/log4j2.xml ${DATACLAY_LOG_CONFIG}

# ================= SERVICE ==================== #
ENTRYPOINT ["dataclay-java-entry-point", "es.bsc.dataclay.logic.server.LogicModuleSrv","--service"] 

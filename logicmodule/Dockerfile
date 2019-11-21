ARG BASE_VERSION
FROM bscdataclay/base:${BASE_VERSION}
LABEL maintainer dataClay team <support-dataclay@bsc.es>

# First get the pom 
COPY ./javaclay/pom.xml ${DATACLAY_HOME}/pom.xml

# The first time you build this (docker build .) the dependencies are downloaded and as step 2 the application jar is build.
# When you rebuild immediately the dependencies (pom.xml) and the application sources were not changed. So, the image layers don't need to be changed. The build is ready in no time.
# If you change 1 of your application source files, only a few downloads are downloaded and the application is build. So you are NOT downloading the world.
# If you change the pom.xml file, thus changing the dependencies, then all dependency downloads are done.
RUN mvn verify clean --fail-never
RUN mvn dependency:go-offline
# Force mvn exec plugin to be downloaded
RUN mvn exec:help
RUN mvn exec:java -Dexec.skip=true

# Copy source code
COPY ./javaclay/ .

# install it
RUN mvn clean install -DskipTests=true

ARG JDK=11
# Install javaclay packages:
RUN apt-get update \
        && apt-get install --no-install-recommends -y --allow-unauthenticated openjdk-${JDK}-jdk \
        && rm -rf /var/lib/apt/lists/*
        
# Set Java home. We create a symbolic link to be arch-independant 
RUN ln -s /usr/lib/jvm/java-${JDK}-openjdk* /usr/lib/jvm/java-${JDK}
ENV JAVA_HOME=/usr/lib/jvm/java-${JDK}
RUN update-alternatives --install "/usr/bin/java" "java" ${JAVA_HOME}/bin/java 99999 && \
	update-alternatives --install "/usr/bin/javac" "javac" ${JAVA_HOME}/bin/javac 99999 && \
	update-alternatives --set java ${JAVA_HOME}/bin/java && \
	update-alternatives --set javac ${JAVA_HOME}/bin/javac


# Configure default logging
ENV DATACLAY_LOG_CONFIG=${DATACLAY_HOME}/logging/log4j2.xml

# Copy entrypoint
COPY ./dataclay-mvn-entry-point.sh ${DATACLAY_HOME}/entrypoints/dataclay-mvn-entry-point

# Modify path for entrypoints
ENV PATH=${DATACLAY_HOME}/entrypoints:${PATH}

# Copy healthcheck
COPY ./health_check.sh ${DATACLAY_HOME}/health/health_check.sh

# Copy configurations and dynamic files (more likely to be changed)
COPY ./javaclay/dataclay-common/cfglog/log4j2.xml ${DATACLAY_LOG_CONFIG}

# ================= SERVICE ==================== #
ENTRYPOINT ["dataclay-mvn-entry-point", "-Dexec.mainClass=es.bsc.dataclay.logic.server.LogicModuleSrv"] 

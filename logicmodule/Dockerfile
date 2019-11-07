ARG BASE_VERSION
FROM bscdataclay/base:${BASE_VERSION}
LABEL maintainer dataClay team <support-dataclay@bsc.es>

# First get the pom 
RUN mkdir -p javaclay
COPY ./javaclay/pom.xml /usr/src/dataclay/javaclay/pom.xml

# change working dir
WORKDIR /usr/src/dataclay/javaclay

# The first time you build this (docker build .) the dependencies are downloaded and as step 2 the application jar is build.
# When you rebuild immediately the dependencies (pom.xml) and the application sources were not changed. So, the image layers don't need to be changed. The build is ready in no time.
# If you change 1 of your application source files, only a few downloads are downloaded and the application is build. So you are NOT downloading the world.
# If you change the pom.xml file, thus changing the dependencies, then all dependency downloads are done.
RUN mvn verify clean --fail-never

# Copy source code
COPY ./javaclay/	.

# install it
RUN mvn install

# Copy entrypoint
COPY ./mvn-entry-point.sh /usr/src/dataclay/mvn-entry-point.sh

# Copy healthcheck
COPY ./health_check.sh /usr/src/dataclay/health_check.sh

# Copy configurations and dynamic files (more likely to be changed)
COPY ./javaclay/dataclay-common/cfglog/log4j2.xml ${LOG4J_CLASSPATH}

# ================= SERVICE ==================== #
ENTRYPOINT ["/usr/src/dataclay/mvn-entry-point.sh", "-Dexec.mainClass=es.bsc.dataclay.logic.server.LogicModuleSrv"] 

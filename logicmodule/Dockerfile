ARG BASE_VERSION
FROM bscdataclay/base:${BASE_VERSION}
LABEL maintainer dataClay team <support-dataclay@bsc.es>

# =============== PREPARE =================== #

COPY ./start_service.sh start_service.sh
COPY ./health_check.sh health_check.sh

# =============== INSTALL JAVACLAY =================== #

COPY ./javaclay	javaclay
# change working dir
WORKDIR /usr/src/dataclay/javaclay
RUN mvn install

#RUN cd javaclay && mvn dependency:copy-dependencies -DoutputDirectory=/usr/src/dataclay/lib package -DskipTests=true
#RUN mv /usr/src/dataclay/javaclay/target/dataclay* ${DATACLAY_JAR}

# =============== ASPECTS =================== #

# Move aspectj libraries for usability
#RUN mv /usr/src/dataclay/lib/aspectjrt* ${ASPECTJ_RT}
#RUN mv /usr/src/dataclay/lib/aspectjweaver* ${ASPECTJ_WEAVER}

# Compile default extrae aspects 
#RUN ajc ${DEFAULT_EXTRAE_ASPECTS}/*.aj -cp ${ASPECTJ_RT}:${DATACLAY_JAR} -outxml -outjar ${DEFAULT_EXTRAE_ASPECTS_JAR}

# =============== DEFAULT CONFIGURATION =================== #

# Copy configurations and dynamic files (more likely to be changed)
COPY ./javaclay/dataclay-common/cfglog/log4j2.xml ${LOG4J_CLASSPATH}

# ================= SERVICE ==================== #
ENTRYPOINT ["mvn", "exec:exec", "-Dlog4j.configurationFile=$LOG4J_CLASSPATH", "-Dexec.mainClass=es.bsc.dataclay.logic.server.LogicModuleSrv"] 

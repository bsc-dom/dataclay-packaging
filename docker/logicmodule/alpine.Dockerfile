ARG BASE_VERSION
FROM bscdataclay/base:${BASE_VERSION}
LABEL maintainer dataClay team <support-dataclay@bsc.es>

ARG LOCAL_JAR="*-jar-with-dependencies.jar"
ARG JDK=11

# Install javaclay packages:
RUN apk --no-cache add openjdk${JDK}-jre
#RUN apk add --no-cache curl tar bash procps
RUN apk add --no-cache sqlite=3.32.1-r0 sqlite-dev=3.32.1-r0

# Downloading and installing Maven
# 1- Define a constant with the version of maven you want to install
#ARG MAVEN_VERSION=3.6.3        

# 2- Define a constant with the working directory
#ARG USER_HOME_DIR="/root"

# 3- Define the SHA key to validate the maven download
#ARG SHA=c35a1803a6e70a126e80b2b3ae33eed961f83ed74d18fcd16909b2d44d7dada3203f1ffe726c17ef8dcca2dcaa9fca676987befeadc9b9f759967a8cb77181c0

# 4- Define the URL where maven can be downloaded from
#ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

# 5- Create the directories, download maven, validate the download, install it, remove downloaded file and set links
#RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
#  && echo "Downlaoding maven" \
#  && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
#  \
#  && echo "Checking download hash" \
#  && echo "${SHA}  /tmp/apache-maven.tar.gz" | sha512sum -c - \
#  \
#  && echo "Unziping maven" \
#  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
#  \
#  && echo "Cleaning and setting links" \
#  && rm -f /tmp/apache-maven.tar.gz \
#  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

# 6- Define environmental variables required by Maven, like Maven_Home directory and where the maven repo is located
# ENV MAVEN_HOME /usr/share/maven
# ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

# Configure dataclay environment variables
ENV DATACLAY_LOG_CONFIG=${DATACLAY_HOME}/logging/log4j2.xml
ENV DATACLAY_JAR=${DATACLAY_HOME}/dataclay.jar

# Get dataClay JAR 
COPY ./javaclay/target/${LOCAL_JAR} ${DATACLAY_JAR}
ENV CLASSPATH=${DATACLAY_JAR}:${CLASSPATH}

# Copy entrypoint
COPY ./dataclay-java-entry-point.sh ${DATACLAY_HOME}/entrypoints/dataclay-java-entry-point
#COPY ./dataclay-mvn-entry-point.sh ${DATACLAY_HOME}/entrypoints/dataclay-mvn-entry-point

# Modify path for entrypoints
ENV PATH=${DATACLAY_HOME}/entrypoints:${PATH}

# Copy healthcheck
COPY ./health_check.sh ${DATACLAY_HOME}/health/health_check.sh

# Copy configurations and dynamic files (more likely to be changed)
COPY ./javaclay/dataclay-common/cfglog/log4j2.xml ${DATACLAY_LOG_CONFIG}

# ================= SERVICE ==================== #
ENTRYPOINT ["sh", "entrypoints/dataclay-java-entry-point", "es.bsc.dataclay.logic.server.LogicModuleSrv","--service"] 

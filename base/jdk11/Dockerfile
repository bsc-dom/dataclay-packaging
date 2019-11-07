#############################################
# Base Dockerfile for dataClay  #
#############################################
FROM ubuntu:18.04
LABEL maintainer dataClay team <support-dataclay@bsc.es>
### Extend from ubuntu instead of openjdk specialized image to allow multiple architectures

# ============ PRE-INSTALLATION ================== #

ARG BASE_JAVA_VERSION=11

# Install packages:
RUN apt-get update \
        && apt-get install --no-install-recommends -y --allow-unauthenticated openjdk-${BASE_JAVA_VERSION}-jdk sqlite3 libsqlite3-0 \
        locales aspectj maven \
        && rm -rf /var/lib/apt/lists/*

# Set Java home. We create a symbolic link to be arch-independant 
RUN ln -s /usr/lib/jvm/java-${BASE_JAVA_VERSION}-openjdk* /usr/lib/jvm/java-${BASE_JAVA_VERSION}
ENV JAVA_HOME=/usr/lib/jvm/java-${BASE_JAVA_VERSION}
RUN update-alternatives --install "/usr/bin/java" "java" ${JAVA_HOME}/bin/java 99999 && \
	update-alternatives --install "/usr/bin/javac" "javac" ${JAVA_HOME}/bin/javac 99999 && \
	update-alternatives --set java ${JAVA_HOME}/bin/java && \
	update-alternatives --set javac ${JAVA_HOME}/bin/javac

# LC_CTYPE instanciated for singularity WARNING: do we need to force time zone?
ENV LC_CTYPE=en_US.UTF-8
# Set the locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8  

# Working dir 
WORKDIR /usr/src/dataclay

# ================= ENVIRONMENT VARIABLES ====================== #
ENV LOG4J_CLASSPATH=/usr/src/dataclay/log4j2.xml

ENTRYPOINT ["echo", "This is dataClay's base image: nothing to do here"] 

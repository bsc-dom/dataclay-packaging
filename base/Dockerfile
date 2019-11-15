#############################################
# Base Dockerfile for dataClay  #
#############################################
FROM ubuntu:18.04
LABEL maintainer dataClay team <support-dataclay@bsc.es>
### Extend from ubuntu instead of openjdk specialized image to allow multiple architectures

# ============ PRE-INSTALLATION ================== #

ARG JDK=11

# Install packages:
RUN apt-get update \
        && apt-get install --no-install-recommends -y --allow-unauthenticated openjdk-8-jdk openjdk-${JDK}-jdk sqlite3 libsqlite3-0 \
        build-essential libiberty-dev gfortran libbfd-dev libxml2-dev papi-tools libpapi-dev curl dh-autoreconf locales aspectj maven \
        && rm -rf /var/lib/apt/lists/*

# Set Java 8 home for extrae
RUN ln -s /usr/lib/jvm/java-8-openjdk* /usr/lib/jvm/java-8
ENV JAVA8_HOME=/usr/lib/jvm/java-8

# Set Java home. We create a symbolic link to be arch-independant 
RUN ln -s /usr/lib/jvm/java-${JDK}-openjdk* /usr/lib/jvm/java-${JDK}
ENV JAVA_HOME=/usr/lib/jvm/java-${JDK}
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

# =================== EXTRAE ENVIRONMENT VARIABLES ======================== #
ENV EXTRAE_HOME=/usr/src/extrae
ENV EXTRAE_VERSION=3.6.1
ENV EXTRAE_SKIP_AUTO_LIBRARY_INITIALIZE=1
ENV EXTRAE_JAR_PATH=${EXTRAE_HOME}/lib/javatrace.jar
ENV EXTRAE_CONFIG_FILE=/usr/src/dataclay/extrae/extrae_basic.xml

# =================== EXTRAE INSTALLATION ======================== #
RUN mkdir -p ${EXTRAE_HOME}

ENV EXTRAE_BUILD_FOLDER=/tmp/extrae_build/
RUN mkdir -p ${EXTRAE_BUILD_FOLDER}
RUN curl -SL https://github.com/bsc-performance-tools/extrae/archive/${EXTRAE_VERSION}.tar.gz | tar -xzC ${EXTRAE_BUILD_FOLDER} --strip-components=1

RUN cd ${EXTRAE_BUILD_FOLDER} && \
	./bootstrap && \
	./configure --prefix=$EXTRAE_HOME \
	--without-mpi \
	--without-unwind \
	--without-dyninst \
	--with-papi=/usr/share/papi \
	--with-papi-headers=/usr/include \
	--with-papi-libs=$(dirname $(find /usr/lib | grep libpapi | head -1)) \
	--disable-openmp \
	--disable-smpss \
	--disable-nanos \
	--with-java-aspectj-weaver=/usr/share/java/aspectjweaver.jar \
	--with-java-jdk=${JAVA8_HOME} && \
	make && \
	make install && \
	make distclean && \ 
	rm -rf ${EXTRAE_BUILD_FOLDER}

# Copy extrae configuration files
COPY ./extrae extrae 

# LD preload and other environment configurations 
ENV LD_PRELOAD=${EXTRAE_HOME}/lib/libpttrace.so:${LD_PRELOAD}
ENV PATH=${EXTRAE_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${EXTRAE_HOME}/lib:${LD_LIBRARY_PATH}

# ================= ENVIRONMENT VARIABLES ====================== #

ENV LOG4J_CLASSPATH=/usr/src/dataclay/javaclay/log4j2.xml

# ================= SERVICE ==================== #

ENTRYPOINT ["echo", "This is dataClay's base image: nothing to do here"] 

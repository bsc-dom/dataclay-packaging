#############################################
# Base Dockerfile for dataClay  #
#############################################
FROM ubuntu:18.04
LABEL maintainer dataClay team <support-dataclay@bsc.es>
### Extend from ubuntu instead of openjdk specialized image to allow multiple architectures

# ============ PRE-INSTALLATION ================== #

# Install packages:
RUN apt-get update \
        && apt-get install --no-install-recommends -y --allow-unauthenticated openjdk-8-jdk sqlite3 libsqlite3-0 \
        build-essential libiberty-dev gfortran libbfd-dev libxml2-dev papi-tools libpapi-dev curl dh-autoreconf locales aspectj maven >/dev/null \
        && rm -rf /var/lib/apt/lists/*

# Set Java 8 home for extrae
RUN ln -s /usr/lib/jvm/java-8-openjdk* /usr/lib/jvm/java-8

ENV JAVA8_HOME=/usr/lib/jvm/java-8

# LC_CTYPE instanciated for singularity WARNING: do we need to force time zone?
ENV LC_CTYPE=en_US.UTF-8
# Set the locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG=en_US.UTF-8 
ENV LANGUAGE=en_US:en 
ENV LC_ALL=en_US.UTF-8

# Working dir 
ENV DATACLAY_HOME=/home/dataclayusr/dataclay
RUN mkdir -p ${DATACLAY_HOME}
WORKDIR ${DATACLAY_HOME}

# =================== EXTRAE ENVIRONMENT VARIABLES ======================== #
ENV EXTRAE_HOME=/home/dataclayusr/.extrae
ENV EXTRAE_VERSION=3.5.4
ENV EXTRAE_SKIP_AUTO_LIBRARY_INITIALIZE=1
ENV EXTRAE_JAR_PATH=${EXTRAE_HOME}/lib/javatrace.jar
ENV EXTRAE_CONFIG_FILE=${DATACLAY_HOME}/extrae/extrae_basic.xml

# =================== EXTRAE INSTALLATION ======================== #
RUN mkdir -p ${EXTRAE_HOME}

ENV EXTRAE_BUILD_FOLDER=/tmp/extrae_build/
RUN mkdir -p ${EXTRAE_BUILD_FOLDER}
RUN curl -SL https://github.com/bsc-performance-tools/extrae/archive/${EXTRAE_VERSION}.tar.gz | tar -xzC ${EXTRAE_BUILD_FOLDER} --strip-components=1

#	--disable-nanos \
#	--with-java-aspectj-weaver=/usr/share/java/aspectjweaver.jar \
RUN cd ${EXTRAE_BUILD_FOLDER} && \
	./bootstrap && \
	./configure --prefix=$EXTRAE_HOME \
	--enable-gettimeofday-clock \
	--without-mpi \
	--without-unwind \
	--without-dyninst \
	--without-binutils \
	--with-papi=/usr/share/papi \
	--with-papi-headers=/usr/include \
	--with-papi-libs=$(dirname $(find /usr/lib | grep libpapi | head -1)) \
	--disable-openmp \
	--enable-nanos \
	--disable-smpss \
	--disable-instrument-io \
	--with-java-jdk=${JAVA8_HOME} && \
	make && \
	make install && \
	make distclean && \ 
	rm -rf ${EXTRAE_BUILD_FOLDER}

# Give permissions for extrae
RUN chmod -R ugo+rwx /tmp

# Copy extrae configuration files
COPY ./extrae extrae 

# LD preload and other environment configurations 
ENV LD_PRELOAD=${EXTRAE_HOME}/lib/libpttrace.so:${LD_PRELOAD}
ENV PATH=${EXTRAE_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${EXTRAE_HOME}/lib:${LD_LIBRARY_PATH}
#ENV EXTRAE_SAMPLING_CLOCKTYPE=REAL

# Virtual environment to be inherited from multi-stage docker in client
ENV DATACLAY_VIRTUAL_ENV=${DATACLAY_HOME}/dataclay_venv

# ================= SERVICE ==================== #

ENTRYPOINT ["echo", "This is dataClay's base image: nothing to do here"] 

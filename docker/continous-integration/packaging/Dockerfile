FROM docker:19.03.13

# ensure all builds runs with Buildkit
ENV DOCKER_BUILDKIT=1
# enable full log of Buildkit builds
ENV BUILDKIT_PROGRESS=plain
# enable Buildx integration with docker
ENV DOCKER_CLI_EXPERIMENTAL=enabled

ARG BUILDX_URL=https://github.com/docker/buildx/releases/download/v0.4.2/buildx-v0.4.2.linux-amd64

RUN mkdir -p $HOME/.docker/cli-plugins && \
    wget -O $HOME/.docker/cli-plugins/docker-buildx $BUILDX_URL && \
    chmod a+x $HOME/.docker/cli-plugins/docker-buildx
#FROM appveyor/build-image:minimal-ubuntu-18.04

WORKDIR /appveyor/projects/dataclay-packaging
RUN mkdir -p /init-scripts/
RUN apk update && apk add --no-cache maven qemu git bash
# openjdk8 python3

COPY . /init-scripts/

#ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk
#ENV PATH="$JAVA_HOME/bin:${PATH}"
#RUN rm -f /usr/bin/python && ln -s /usr/bin/python3 /usr/bin/python

#RUN java -version
#RUN javac -version
#RUN python --version

# Install
# ENV DEBIAN_FRONTEND=noninteractive
# curl wget openjdk-11-jdk apt-transport-https unzip build-essential libssl-dev uuid-dev libgpgme11-dev libseccomp-dev pkg-config git cryptsetup
# RUN  apt-get update &&  apt-get install -y --allow-unauthenticated \
#      maven \
#      &&  rm -rf /var/lib/apt/lists/*

#RUN wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
#    &&  dpkg -i packages-microsoft-prod.deb
#RUN  apt-get update &&  apt-get install -y dotnet-runtime-3.1 &&  rm -rf /var/lib/apt/lists/*

# Install java
#RUN  ln -s /usr/lib/jvm/java-11-openjdk* /usr/lib/jvm/java-default
#ENV JAVA_HOME=/usr/lib/jvm/java-default
#ENV PATH=$JAVA_HOME/bin:$PATH

# RUN mvn -version

# Install docker
#RUN  apt-get update &&  apt install -y software-properties-common
#RUN ( curl -fsSL https://download.docker.com/linux/ubuntu/gpg |  apt-key add -) && \
#    apt-add-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \

#RUN apt-get update && \
#    apt-get install -y binfmt-support qemu qemu-user-static jq && \
# RUN   mkdir -p $HOME/.docker/ && \
#    echo "{ \"experimental\":\"enabled\" }" > $HOME/.docker/config.json
#     apt-get -y -o Dpkg::Options::="--force-confnew" install docker-ce && \

# Install go
# RUN wget -q -c https://golang.org/dl/go1.15.6.linux-amd64.tar.gz && \
#     tar -C /usr/local -xvf go1.15.6.linux-amd64.tar.gz && rm go1.15.6.linux-amd64.tar.gz
# ENV PATH=$PATH:/usr/local/go/bin
# RUN go version

# Install singularity
# ENV SINGULARITY_VERSION=3.5.2
# RUN wget --quiet https://github.com/sylabs/singularity/releases/download/v${SINGULARITY_VERSION}/singularity-${SINGULARITY_VERSION}.tar.gz && \
#    tar -xzf singularity-${SINGULARITY_VERSION}.tar.gz && rm singularity-${SINGULARITY_VERSION}.tar.gz

# RUN cd singularity && \
#    ./mconfig && \
#        make -C builddir && \
#         make -C builddir install


# Install mn keys
#RUN curl -sflL 'https://raw.githubusercontent.com/appveyor/secure-file/master/install.sh' | bash -e - && \
#    ls -la ./appveyor-tools/

#CMD [ "/bin/bash", "/scripts/entrypoint.sh" ]

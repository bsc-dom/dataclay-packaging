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
RUN apk update && apk add --no-cache qemu bash
ENTRYPOINT ["bash"]
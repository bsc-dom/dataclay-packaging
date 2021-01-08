FROM alpine:3
# Install
ENV DEBIAN_FRONTEND=noninteractive
RUN apk update && apk add --no-cache openssh bash curl git
RUN apk update && apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing singularity
RUN mkdir /appveyor-tools/ \
    && cd / && curl -sflL 'https://raw.githubusercontent.com/appveyor/secure-file/master/install.sh' | bash -e -
RUN mkdir -p $HOME/.ssh && mkdir -p /scripts/
COPY . /scripts/
ENTRYPOINT ["/scripts/entrypoint.sh"]
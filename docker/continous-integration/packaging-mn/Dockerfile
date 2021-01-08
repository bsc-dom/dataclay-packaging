FROM mcr.microsoft.com/dotnet/sdk:3.1-alpine
# Install
ENV DEBIAN_FRONTEND=noninteractive
RUN apk update && apk add --no-cache openssh bash curl git rsync openjdk11 maven
RUN apk update && apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing singularity
RUN mkdir -p $HOME/.ssh && mkdir -p /scripts/
RUN mkdir /appveyor-tools/ \
    && cd / && curl -sflL 'https://raw.githubusercontent.com/appveyor/secure-file/master/install.sh' | bash -e -
COPY . /scripts/
ENTRYPOINT ["/scripts/entrypoint.sh"]
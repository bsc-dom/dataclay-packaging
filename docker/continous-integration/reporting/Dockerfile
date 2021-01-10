FROM mcr.microsoft.com/dotnet/sdk:3.1-alpine
# Install
ENV DEBIAN_FRONTEND=noninteractive
RUN apk update && apk add --no-cache openjdk11
RUN apk update && apk add --no-cache openssl openssh git bash curl
RUN mkdir -p $HOME/.ssh && mkdir -p /scripts/
RUN mkdir /appveyor-tools/ \
    && cd / && curl -sflL 'https://raw.githubusercontent.com/appveyor/secure-file/master/install.sh' | bash -e -
RUN mkdir -p /scripts/
COPY . /scripts/
RUN dotnet --version
ENTRYPOINT ["/scripts/entrypoint.sh"]
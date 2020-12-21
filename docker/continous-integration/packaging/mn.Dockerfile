FROM alpine:3
# Install
ENV DEBIAN_FRONTEND=noninteractive
RUN apk update && apk add --no-cache openssh
RUN apk update && apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing singularity
RUN mkdir -p $HOME/.ssh && mkdir -p /init-scripts/
COPY ./init.sh /init-scripts/init.sh
COPY ./init_mn.sh /init-scripts/init_mn.sh

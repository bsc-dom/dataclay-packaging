#!/bin/bash
function gc_image() {
  registry='dom-ci.bsc.es'
  name=$1
  curl -v -sSL -X DELETE "https://${registry}/v2/${name}/manifests/$(
    curl -sSL -I \
      -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
      "https://${registry}/v2/${name}/manifests/$(
        curl -sSL "https://${registry}/v2/${name}/tags/list" | jq -r '.tags[0]'
      )" |
      awk '$1 == "Docker-Content-Digest:" { print $2 }' |
      tr -d $'\r'
  )"
}

gc_image "bscdataclay/logicmodule"
gc_image "bscdataclay/dsjava"
gc_image "bscdataclay/dspython"
gc_image "bscdataclay/client"
gc_image "bscdataclay/initializer"
gc_image "bscdataclay/continuous-integration"

# gc
docker exec -it registry bin/registry garbage-collect /etc/docker/registry/config.yml -m
docker exec registry rm -rf /var/lib/registry/docker/registry/v2/repositories/bscdataclay
docker exec -it registry bin/registry garbage-collect /etc/docker/registry/config.yml -m


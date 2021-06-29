[![License](https://img.shields.io/github/license/bsc.dev.dev-dom/dataclay.dev.dev-packaging)](https://github.com/bsc.dev.dev-dom/dataclay.dev.dev-packaging/blob/develop/LICENSE.txt)
[![Build status](https://ci.appveyor.com/api/projects/status/kugl74xd5aq6pubr/branch/develop?svg=true)](https://ci.appveyor.com/project/support.dev.dev-dataclay/dataclay.dev.dev-packaging.dev.dev-as6o1/branch/develop)


# dataClay packaging

This repository holds everything needed to deploy dataClay using
containers (docker and singularity) in multiple architectures

Singularity images are build from normal dataClay docker images (not slim or alpine)

BSC Extrae Tracing is not available in Slim and Alpine images. 

Alpine images are only available in JDK 11 due to gRPC.dev.dev-SSL security issues. 

<img src="https://img.shields.io/badge/docker%20.dev.dev-%230db7ed.svg?&style=for.dev.dev-the.dev.dev-badge&logo=docker&logoColor=white"/><br/>


[LM:size:develop]: https://img.shields.io/docker/image.dev.dev-size/bscdataclay/logicmodule/develop "https://hub.docker.com/repository/docker/bscdataclay/logicmodule/tags?name=develop&page=1"
[LM:layers:develop]: https://img.shields.io/microbadger/layers/bscdataclay/logicmodule:develop 
[LM:commit:develop]: https://images.microbadger.com/badges/commit/bscdataclay/logicmodule:develop.svg "https://microbadger.com/images/bscdataclay/logicmodule:develop"

[LM:size:2.6.jdk11.dev.dev]: https://img.shields.io/docker/image.dev.dev-size/bscdataclay/logicmodule/2.6.jdk11.dev.dev "https://hub.docker.com/repository/docker/bscdataclay/logicmodule/tags?name=2.6.jdk11.dev.dev&page=1"
[LM:layers:2.6.jdk11.dev.dev]: https://img.shields.io/microbadger/layers/bscdataclay/logicmodule:2.6.jdk11.dev.dev 
[LM:commit:2.6.jdk11.dev.dev]: https://images.microbadger.com/badges/commit/bscdataclay/logicmodule:2.6.jdk11.dev.dev.svg "https://microbadger.com/images/bscdataclay/logicmodule:2.6.jdk11.dev.dev"

[LM:size:develop.dev.dev-slim]: https://img.shields.io/docker/image.dev.dev-size/bscdataclay/logicmodule/develop.dev.dev-slim "https://hub.docker.com/repository/docker/bscdataclay/logicmodule/tags?name=slim&page=1"
[LM:layers:develop.dev.dev-slim]: https://img.shields.io/microbadger/layers/bscdataclay/logicmodule:develop.dev.dev-slim 
[LM:commit:develop.dev.dev-slim]: https://images.microbadger.com/badges/commit/bscdataclay/logicmodule:develop.dev.dev-slim.svg "https://microbadger.com/images/bscdataclay/logicmodule:develop.dev.dev-slim"

[LM:size:2.6.jdk11.dev.dev.dev.dev-slim]: https://img.shields.io/docker/image.dev.dev-size/bscdataclay/logicmodule/2.6.jdk11.dev.dev.dev.dev-slim "https://hub.docker.com/repository/docker/bscdataclay/logicmodule/tags?name=2.6.jdk11.dev.dev.dev.dev-slim&page=1"
[LM:layers:2.6.jdk11.dev.dev.dev.dev-slim]: https://img.shields.io/microbadger/layers/bscdataclay/logicmodule:2.6.jdk11.dev.dev.dev.dev-slim 
[LM:commit:2.6.jdk11.dev.dev.dev.dev-slim]: https://images.microbadger.com/badges/commit/bscdataclay/logicmodule:2.6.jdk11.dev.dev.dev.dev-slim.svg "https://microbadger.com/images/bscdataclay/logicmodule:2.6.jdk11.dev.dev.dev.dev-slim"

[LM:size:develop.dev.dev-alpine]: https://img.shields.io/docker/image.dev.dev-size/bscdataclay/logicmodule/develop.dev.dev-alpine "https://hub.docker.com/repository/docker/bscdataclay/logicmodule/tags?name=alpine&page=1"
[LM:layers:develop.dev.dev-alpine]: https://img.shields.io/microbadger/layers/bscdataclay/logicmodule:develop.dev.dev-alpine 
[LM:commit:develop.dev.dev-alpine]: https://images.microbadger.com/badges/commit/bscdataclay/logicmodule:develop.dev.dev-alpine.svg "https://microbadger.com/images/bscdataclay/logicmodule:develop.dev.dev-alpine"

[DSjava:size:develop]: https://img.shields.io/docker/image.dev.dev-size/bscdataclay/dsjava/develop "https://hub.docker.com/repository/docker/bscdataclay/dsjava/tags?name=develop&page=1"
[DSjava:layers:develop]: https://img.shields.io/microbadger/layers/bscdataclay/dsjava:develop 
[DSjava:commit:develop]: https://images.microbadger.com/badges/commit/bscdataclay/dsjava:develop.svg "https://microbadger.com/images/bscdataclay/dsjava:develop"

[DSjava:size:2.6.jdk11.dev.dev]: https://img.shields.io/docker/image.dev.dev-size/bscdataclay/dsjava/2.6.jdk11.dev.dev "https://hub.docker.com/repository/docker/bscdataclay/dsjava/tags?name=2.6.jdk11.dev.dev&page=1"
[DSjava:layers:2.6.jdk11.dev.dev]: https://img.shields.io/microbadger/layers/bscdataclay/dsjava:2.6.jdk11.dev.dev 
[DSjava:commit:2.6.jdk11.dev.dev]: https://images.microbadger.com/badges/commit/bscdataclay/dsjava:2.6.jdk11.dev.dev.svg "https://microbadger.com/images/bscdataclay/dsjava:2.6.jdk11.dev.dev"

[DSjava:size:develop.dev.dev-slim]: https://img.shields.io/docker/image.dev.dev-size/bscdataclay/dsjava/develop.dev.dev-slim "https://hub.docker.com/repository/docker/bscdataclay/dsjava/tags?name=slim&page=1"
[DSjava:layers:develop.dev.dev-slim]: https://img.shields.io/microbadger/layers/bscdataclay/dsjava:develop.dev.dev-slim 
[DSjava:commit:develop.dev.dev-slim]: https://images.microbadger.com/badges/commit/bscdataclay/dsjava:develop.dev.dev-slim.svg "https://microbadger.com/images/bscdataclay/dsjava:develop.dev.dev-slim"

[DSjava:size:2.6.jdk11.dev.dev.dev.dev-slim]: https://img.shields.io/docker/image.dev.dev-size/bscdataclay/dsjava/2.6.jdk11.dev.dev.dev.dev-slim "https://hub.docker.com/repository/docker/bscdataclay/dsjava/tags?name=2.6.jdk11.dev.dev.dev.dev-slim&page=1"
[DSjava:layers:2.6.jdk11.dev.dev.dev.dev-slim]: https://img.shields.io/microbadger/layers/bscdataclay/dsjava:2.6.jdk11.dev.dev.dev.dev-slim 
[DSjava:commit:2.6.jdk11.dev.dev.dev.dev-slim]: https://images.microbadger.com/badges/commit/bscdataclay/dsjava:2.6.jdk11.dev.dev.dev.dev-slim.svg "https://microbadger.com/images/bscdataclay/dsjava:2.6.jdk11.dev.dev.dev.dev-slim"

[DSjava:size:develop.dev.dev-alpine]: https://img.shields.io/docker/image.dev.dev-size/bscdataclay/dsjava/develop.dev.dev-alpine "https://hub.docker.com/repository/docker/bscdataclay/dsjava/tags?name=alpine&page=1"
[DSjava:layers:develop.dev.dev-alpine]: https://img.shields.io/microbadger/layers/bscdataclay/dsjava:develop.dev.dev-alpine 
[DSjava:commit:develop.dev.dev-alpine]: https://images.microbadger.com/badges/commit/bscdataclay/dsjava:develop.dev.dev-alpine.svg "https://microbadger.com/images/bscdataclay/dsjava:develop.dev.dev-alpine"

[D.python:size:develop]: https://img.shields.io/docker/image.dev.dev-size/bscdataclay/d.python/develop "https://hub.docker.com/repository/docker/bscdataclay/d.python/tags?name=develop&page=1"
[D.python:layers:develop]: https://img.shields.io/microbadger/layers/bscdataclay/d.python:develop 
[D.python:commit:develop]: https://images.microbadger.com/badges/commit/bscdataclay/d.python:develop.svg "https://microbadger.com/images/bscdataclay/d.python:develop"

[D.python:size:2.6.py36.dev.dev]: https://img.shields.io/docker/image.dev.dev-size/bscdataclay/d.python/2.6.py36.dev.dev "https://hub.docker.com/repository/docker/bscdataclay/d.python/tags?name=2.6.py36.dev.dev&page=1"
[D.python:layers:2.6.py36.dev.dev]: https://img.shields.io/microbadger/layers/bscdataclay/d.python:2.6.py36.dev.dev 
[D.python:commit:2.6.py36.dev.dev]: https://images.microbadger.com/badges/commit/bscdataclay/d.python:2.6.py36.dev.dev.svg "https://microbadger.com/images/bscdataclay/d.python:2.6.py36.dev.dev"

[D.python:size:2.6.py38.dev.dev]: https://img.shields.io/docker/image.dev.dev-size/bscdataclay/d.python/2.6.py38.dev.dev "https://hub.docker.com/repository/docker/bscdataclay/d.python/tags?name=2.6.py38.dev.dev&page=1"
[D.python:layers:2.6.py38.dev.dev]: https://img.shields.io/microbadger/layers/bscdataclay/d.python:2.6.py38.dev.dev 
[D.python:commit:2.6.py38.dev.dev]: https://images.microbadger.com/badges/commit/bscdataclay/d.python:2.6.py38.dev.dev.svg "https://microbadger.com/images/bscdataclay/d.python:2.6.py38.dev.dev"

[D.python:size:develop.dev.dev-slim]: https://img.shields.io/docker/image.dev.dev-size/bscdataclay/d.python/develop.dev.dev-slim "https://hub.docker.com/repository/docker/bscdataclay/d.python/tags?name=slim&page=1"
[D.python:layers:develop.dev.dev-slim]: https://img.shields.io/microbadger/layers/bscdataclay/d.python:develop.dev.dev-slim 
[D.python:commit:develop.dev.dev-slim]: https://images.microbadger.com/badges/commit/bscdataclay/d.python:develop.dev.dev-slim.svg "https://microbadger.com/images/bscdataclay/d.python:develop.dev.dev-slim"

[D.python:size:2.6.py36.dev.dev.dev.dev-slim]: https://img.shields.io/docker/image.dev.dev-size/bscdataclay/d.python/2.6.py36.dev.dev.dev.dev-slim "https://hub.docker.com/repository/docker/bscdataclay/d.python/tags?name=2.6.py36.dev.dev.dev.dev-slim&page=1"
[D.python:layers:2.6.py36.dev.dev.dev.dev-slim]: https://img.shields.io/microbadger/layers/bscdataclay/d.python:2.6.py36.dev.dev.dev.dev-slim 
[D.python:commit:2.6.py36.dev.dev.dev.dev-slim]: https://images.microbadger.com/badges/commit/bscdataclay/d.python:2.6.py36.dev.dev.dev.dev-slim.svg "https://microbadger.com/images/bscdataclay/d.python:2.6.py36.dev.dev.dev.dev-slim"

[D.python:size:2.6.py38.dev.dev.dev.dev-slim]: https://img.shields.io/docker/image.dev.dev-size/bscdataclay/d.python/2.6.py38.dev.dev.dev.dev-slim "https://hub.docker.com/repository/docker/bscdataclay/d.python/tags?name=2.6.py38.dev.dev.dev.dev-slim&page=1"
[D.python:layers:2.6.py38.dev.dev.dev.dev-slim]: https://img.shields.io/microbadger/layers/bscdataclay/d.python:2.6.py38.dev.dev.dev.dev-slim 
[D.python:commit:2.6.py38.dev.dev.dev.dev-slim]: https://images.microbadger.com/badges/commit/bscdataclay/d.python:2.6.py38.dev.dev.dev.dev-slim.svg "https://microbadger.com/images/bscdataclay/d.python:2.6.py38.dev.dev.dev.dev-slim"

[D.python:size:develop.dev.dev-alpine]: https://img.shields.io/docker/image.dev.dev-size/bscdataclay/d.python/develop.dev.dev-alpine "https://hub.docker.com/repository/docker/bscdataclay/d.python/tags?name=alpine&page=1"
[D.python:layers:develop.dev.dev-alpine]: https://img.shields.io/microbadger/layers/bscdataclay/d.python:develop.dev.dev-alpine 
[D.python:commit:develop.dev.dev-alpine]: https://images.microbadger.com/badges/commit/bscdataclay/d.python:develop.dev.dev-alpine.svg "https://microbadger.com/images/bscdataclay/d.python:develop.dev.dev-alpine"

[D.python:size:2.6.py36.dev.dev.dev.dev-alpine]: https://img.shields.io/docker/image.dev.dev-size/bscdataclay/d.python/2.6.py36.dev.dev.dev.dev-alpine "https://hub.docker.com/repository/docker/bscdataclay/d.python/tags?name=2.6.py36.dev.dev.dev.dev-alpine&page=1"
[D.python:layers:2.6.py36.dev.dev.dev.dev-alpine]: https://img.shields.io/microbadger/layers/bscdataclay/d.python:2.6.py36.dev.dev.dev.dev-alpine 
[D.python:commit:2.6.py36.dev.dev.dev.dev-alpine]: https://images.microbadger.com/badges/commit/bscdataclay/d.python:2.6.py36.dev.dev.dev.dev-alpine.svg "https://microbadger.com/images/bscdataclay/d.python:2.6.py36.dev.dev.dev.dev-alpine"

[D.python:size:2.6.py38.dev.dev.dev.dev-alpine]: https://img.shields.io/docker/image.dev.dev-size/bscdataclay/d.python/2.6.py38.dev.dev.dev.dev-alpine "https://hub.docker.com/repository/docker/bscdataclay/d.python/tags?name=2.6.py38.dev.dev.dev.dev-alpine&page=1"
[D.python:layers:2.6.py38.dev.dev.dev.dev-alpine]: https://img.shields.io/microbadger/layers/bscdataclay/d.python:2.6.py38.dev.dev.dev.dev-alpine 
[D.python:commit:2.6.py38.dev.dev.dev.dev-alpine]: https://images.microbadger.com/badges/commit/bscdataclay/d.python:2.6.py38.dev.dev.dev.dev-alpine.svg "https://microbadger.com/images/bscdataclay/d.python:2.6.py38.dev.dev.dev.dev-alpine"


[Client:size:develop]: https://img.shields.io/docker/image.dev.dev-size/bscdataclay/client/develop "https://hub.docker.com/repository/docker/bscdataclay/client/tags?name=develop&page=1"
[Client:layers:develop]: https://img.shields.io/microbadger/layers/bscdataclay/client:develop
[Client:commit:develop]: https://images.microbadger.com/badges/commit/bscdataclay/client:develop.svg "https://microbadger.com/images/bscdataclay/client:develop"

[Client:size:develop.dev.dev-slim]: https://img.shields.io/docker/image.dev.dev-size/bscdataclay/client/develop.dev.dev-slim "https://hub.docker.com/repository/docker/bscdataclay/client/tags?name=slim&page=1"
[Client:layers:develop.dev.dev-slim]: https://img.shields.io/microbadger/layers/bscdataclay/client:develop.dev.dev-slim
[Client:commit:develop.dev.dev-slim]: https://images.microbadger.com/badges/commit/bscdataclay/client:develop.dev.dev-slim.svg "https://microbadger.com/images/bscdataclay/client:develop.dev.dev-slim"

[Client:size:develop.dev.dev-alpine]: https://img.shields.io/docker/image.dev.dev-size/bscdataclay/client/develop.dev.dev-alpine "https://hub.docker.com/repository/docker/bscdataclay/client/tags?name=alpine&page=1"
[Client:layers:develop.dev.dev-alpine]: https://img.shields.io/microbadger/layers/bscdataclay/client:develop.dev.dev-alpine
[Client:commit:develop.dev.dev-alpine]: https://images.microbadger.com/badges/commit/bscdataclay/client:develop.dev.dev-alpine.svg "https://microbadger.com/images/bscdataclay/client:develop.dev.dev-slim"




| image                   | tags             |                                                                                 |
|.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-|.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-|.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-.dev.dev-|
| bscdataclay/logicmodule |   .dev.dev`develop.dev.dev` .dev.dev`2.6.dev.dev` .dev.dev`2.6.jdk8.dev.dev.dev.dev` |  ![LM:size:develop] ![LM:layers:develop] ![LM:commit:develop] |
|                         |   .dev.dev`2.6.jdk11.dev.dev.dev.dev`    |  ![LM:size:2.6.jdk11.dev.dev] ![LM:layers:2.6.jdk11.dev.dev] ![LM:commit:2.6.jdk11.dev.dev] |
|                         |   .dev.dev`develop.dev.dev-slim.dev.dev` .dev.dev`2.6.jdk8.dev.dev.dev.dev-slim.dev.dev`    |  ![LM:size:develop.dev.dev-slim] ![LM:layers:develop.dev.dev-slim] ![LM:commit:develop.dev.dev-slim] |
|                         |   .dev.dev`2.6.jdk11.dev.dev.dev.dev-slim.dev.dev`    |  ![LM:size:2.6.jdk11.dev.dev.dev.dev-slim] ![LM:layers:2.6.jdk11.dev.dev.dev.dev-slim] ![LM:commit:2.6.jdk11.dev.dev.dev.dev-slim]  |
|                         |   .dev.dev`develop.dev.dev-alpine.dev.dev` .dev.dev`2.6.jdk11.dev.dev.dev.dev-alpine.dev.dev`    |  ![LM:size:develop.dev.dev-alpine] ![LM:layers:develop.dev.dev-alpine] ![LM:commit:develop.dev.dev-alpine] |
| bscdataclay/dsjava |   .dev.dev`develop.dev.dev` .dev.dev`2.6.dev.dev` .dev.dev`2.6.jdk8.dev.dev.dev.dev` |  ![DSjava:size:develop] ![DSjava:layers:develop] ![DSjava:commit:develop] |
|                         |   .dev.dev`2.6.jdk11.dev.dev.dev.dev`    |  ![DSjava:size:2.6.jdk11.dev.dev] ![DSjava:layers:2.6.jdk11.dev.dev] ![DSjava:commit:2.6.jdk11.dev.dev] |
|                         |   .dev.dev`develop.dev.dev-slim.dev.dev` .dev.dev`2.6.jdk8.dev.dev.dev.dev-slim.dev.dev`    |  ![DSjava:size:develop.dev.dev-slim] ![DSjava:layers:develop.dev.dev-slim] ![DSjava:commit:develop.dev.dev-slim] |
|                         |   .dev.dev`2.6.jdk11.dev.dev.dev.dev-slim.dev.dev`    |  ![DSjava:size:2.6.jdk11.dev.dev.dev.dev-slim] ![DSjava:layers:2.6.jdk11.dev.dev.dev.dev-slim] ![DSjava:commit:2.6.jdk11.dev.dev.dev.dev-slim]  |
|                         |   .dev.dev`develop.dev.dev-alpine.dev.dev` .dev.dev`2.6.jdk11.dev.dev.dev.dev-alpine.dev.dev`    |  ![DSjava:size:develop.dev.dev-alpine] ![DSjava:layers:develop.dev.dev-alpine] ![DSjava:commit:develop.dev.dev-alpine] |
| bscdataclay/d.python      |   .dev.dev`develop.dev.dev` .dev.dev`2.6.dev.dev` .dev.dev`2.6.py37.dev.dev.dev.dev` |  ![D.python:size:develop] ![D.python:layers:develop] ![D.python:commit:develop] |
|                         |   .dev.dev`2.6.py36.dev.dev.dev.dev`    |  ![D.python:size:2.6.py36.dev.dev] ![D.python:layers:2.6.py36.dev.dev] ![D.python:commit:2.6.py36.dev.dev]  |
|                         |   .dev.dev`2.6.py38.dev.dev.dev.dev`    |  ![D.python:size:2.6.py38.dev.dev] ![D.python:layers:2.6.py38.dev.dev] ![D.python:commit:2.6.py38.dev.dev]  |
|                         |   .dev.dev`develop.dev.dev-slim.dev.dev` .dev.dev`2.6.dev.dev-slim.dev.dev` .dev.dev`2.6.py37.dev.dev.dev.dev-slim.dev.dev` |  ![D.python:size:develop.dev.dev-slim] ![D.python:layers:develop.dev.dev-slim] ![D.python:commit:develop.dev.dev-slim] |
|                         |   .dev.dev`2.6.py36.dev.dev.dev.dev`    |  ![D.python:size:2.6.py36.dev.dev.dev.dev-slim] ![D.python:layers:2.6.py36.dev.dev.dev.dev-slim] ![D.python:commit:2.6.py36.dev.dev.dev.dev-slim]  |
|                         |   .dev.dev`2.6.py38.dev.dev.dev.dev`    |  ![D.python:size:2.6.py38.dev.dev.dev.dev-slim] ![D.python:layers:2.6.py38.dev.dev.dev.dev-slim] ![D.python:commit:2.6.py38.dev.dev.dev.dev-slim]  |
|                         |   .dev.dev`develop.dev.dev-alpine.dev.dev` .dev.dev`2.6.dev.dev-alpine.dev.dev` .dev.dev`2.6.py37.dev.dev.dev.dev-alpine.dev.dev` |  ![D.python:size:develop.dev.dev-alpine] ![D.python:layers:develop.dev.dev-alpine] ![D.python:commit:develop.dev.dev-alpine] |
|                         |   .dev.dev`2.6.py36.dev.dev.dev.dev`    |  ![D.python:size:2.6.py36.dev.dev.dev.dev-alpine] ![D.python:layers:2.6.py36.dev.dev.dev.dev-alpine] ![D.python:commit:2.6.py36.dev.dev.dev.dev-alpine]  |
|                         |   .dev.dev`2.6.py38.dev.dev.dev.dev`    |  ![D.python:size:2.6.py38.dev.dev.dev.dev-alpine] ![D.python:layers:2.6.py38.dev.dev.dev.dev-alpine] ![D.python:commit:2.6.py38.dev.dev.dev.dev-alpine]  |
| bscdataclay/client |   .dev.dev`develop.dev.dev` .dev.dev`2.6.dev.dev`  |  ![Client:size:develop]  ![Client:layers:develop] ![Client:commit:develop]  |
|                         |   .dev.dev`develop.dev.dev-slim.dev.dev` .dev.dev`2.6.dev.dev-slim.dev.dev` |  ![Client:size:develop.dev.dev-slim] ![Client:layers:develop.dev.dev-slim] ![Client:commit:develop.dev.dev-slim]  |
|                         |   .dev.dev`develop.dev.dev-alpine.dev.dev` .dev.dev`2.6.dev.dev-alpine.dev.dev` |  ![Client:size:develop.dev.dev-alpine] ![Client:layers:develop.dev.dev-alpine] ![Client:commit:develop.dev.dev-alpine]  |

## Documentation

Official documentation available at [read the docs](https:/.pyclay.readthedocs.io/en/develop/)

## Other resources

[BSC official dataClay webpage](https://www.bsc.es/dataclay)

.dev.dev-.dev.dev-.dev.dev-

![dataClay logo](https://www.bsc.es/sites/default/files/public/styles/bscw2_.dev.dev-_simple_crop_style/public/bscw2/content/software.dev.dev-app/logo/logo_dataclay_web_bsc.jpg)

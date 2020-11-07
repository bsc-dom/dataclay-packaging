[![License](https://img.shields.io/github/license/bsc-dom/dataclay-packaging)](https://github.com/bsc-dom/dataclay-packaging/blob/latest/LICENSE.txt)

# dataClay packaging

This repository holds everything needed to deploy dataClay using
containers (docker and singularity) in multiple architectures

Singularity images are build from normal dataClay docker images (not slim or alpine)

BSC Extrae Tracing is not available in Slim and Alpine images. 

Alpine images are only available in JDK 11 due to gRPC-SSL security issues. 

<img src="https://img.shields.io/badge/docker%20-%230db7ed.svg?&style=for-the-badge&logo=docker&logoColor=white"/><br/>


[LM:size:latest]: https://img.shields.io/docker/image-size/bscdataclay/logicmodule/latest "https://hub.docker.com/repository/docker/bscdataclay/logicmodule/tags?name=latest&page=1"
[LM:layers:latest]: https://img.shields.io/microbadger/layers/bscdataclay/logicmodule:latest 
[LM:commit:latest]: https://images.microbadger.com/badges/commit/bscdataclay/logicmodule:latest.svg "https://microbadger.com/images/bscdataclay/logicmodule:latest"

[LM:size:2.5.jdk11]: https://img.shields.io/docker/image-size/bscdataclay/logicmodule/2.5.jdk11 "https://hub.docker.com/repository/docker/bscdataclay/logicmodule/tags?name=2.5.jdk11&page=1"
[LM:layers:2.5.jdk11]: https://img.shields.io/microbadger/layers/bscdataclay/logicmodule:2.5.jdk11 
[LM:commit:2.5.jdk11]: https://images.microbadger.com/badges/commit/bscdataclay/logicmodule:2.5.jdk11.svg "https://microbadger.com/images/bscdataclay/logicmodule:2.5.jdk11"

[LM:size:slim]: https://img.shields.io/docker/image-size/bscdataclay/logicmodule/slim "https://hub.docker.com/repository/docker/bscdataclay/logicmodule/tags?name=slim&page=1"
[LM:layers:slim]: https://img.shields.io/microbadger/layers/bscdataclay/logicmodule:slim 
[LM:commit:slim]: https://images.microbadger.com/badges/commit/bscdataclay/logicmodule:slim.svg "https://microbadger.com/images/bscdataclay/logicmodule:slim"

[LM:size:2.5.jdk11-slim]: https://img.shields.io/docker/image-size/bscdataclay/logicmodule/2.5.jdk11-slim "https://hub.docker.com/repository/docker/bscdataclay/logicmodule/tags?name=2.5.jdk11-slim&page=1"
[LM:layers:2.5.jdk11-slim]: https://img.shields.io/microbadger/layers/bscdataclay/logicmodule:2.5.jdk11-slim 
[LM:commit:2.5.jdk11-slim]: https://images.microbadger.com/badges/commit/bscdataclay/logicmodule:2.5.jdk11-slim.svg "https://microbadger.com/images/bscdataclay/logicmodule:2.5.jdk11-slim"

[LM:size:alpine]: https://img.shields.io/docker/image-size/bscdataclay/logicmodule/alpine "https://hub.docker.com/repository/docker/bscdataclay/logicmodule/tags?name=alpine&page=1"
[LM:layers:alpine]: https://img.shields.io/microbadger/layers/bscdataclay/logicmodule:alpine 
[LM:commit:alpine]: https://images.microbadger.com/badges/commit/bscdataclay/logicmodule:alpine.svg "https://microbadger.com/images/bscdataclay/logicmodule:alpine"

[DSjava:size:latest]: https://img.shields.io/docker/image-size/bscdataclay/dsjava/latest "https://hub.docker.com/repository/docker/bscdataclay/dsjava/tags?name=latest&page=1"
[DSjava:layers:latest]: https://img.shields.io/microbadger/layers/bscdataclay/dsjava:latest 
[DSjava:commit:latest]: https://images.microbadger.com/badges/commit/bscdataclay/dsjava:latest.svg "https://microbadger.com/images/bscdataclay/dsjava:latest"

[DSjava:size:2.5.jdk11]: https://img.shields.io/docker/image-size/bscdataclay/dsjava/2.5.jdk11 "https://hub.docker.com/repository/docker/bscdataclay/dsjava/tags?name=2.5.jdk11&page=1"
[DSjava:layers:2.5.jdk11]: https://img.shields.io/microbadger/layers/bscdataclay/dsjava:2.5.jdk11 
[DSjava:commit:2.5.jdk11]: https://images.microbadger.com/badges/commit/bscdataclay/dsjava:2.5.jdk11.svg "https://microbadger.com/images/bscdataclay/dsjava:2.5.jdk11"

[DSjava:size:slim]: https://img.shields.io/docker/image-size/bscdataclay/dsjava/slim "https://hub.docker.com/repository/docker/bscdataclay/dsjava/tags?name=slim&page=1"
[DSjava:layers:slim]: https://img.shields.io/microbadger/layers/bscdataclay/dsjava:slim 
[DSjava:commit:slim]: https://images.microbadger.com/badges/commit/bscdataclay/dsjava:slim.svg "https://microbadger.com/images/bscdataclay/dsjava:slim"

[DSjava:size:2.5.jdk11-slim]: https://img.shields.io/docker/image-size/bscdataclay/dsjava/2.5.jdk11-slim "https://hub.docker.com/repository/docker/bscdataclay/dsjava/tags?name=2.5.jdk11-slim&page=1"
[DSjava:layers:2.5.jdk11-slim]: https://img.shields.io/microbadger/layers/bscdataclay/dsjava:2.5.jdk11-slim 
[DSjava:commit:2.5.jdk11-slim]: https://images.microbadger.com/badges/commit/bscdataclay/dsjava:2.5.jdk11-slim.svg "https://microbadger.com/images/bscdataclay/dsjava:2.5.jdk11-slim"

[DSjava:size:alpine]: https://img.shields.io/docker/image-size/bscdataclay/dsjava/alpine "https://hub.docker.com/repository/docker/bscdataclay/dsjava/tags?name=alpine&page=1"
[DSjava:layers:alpine]: https://img.shields.io/microbadger/layers/bscdataclay/dsjava:alpine 
[DSjava:commit:alpine]: https://images.microbadger.com/badges/commit/bscdataclay/dsjava:alpine.svg "https://microbadger.com/images/bscdataclay/dsjava:alpine"

[DSpython:size:latest]: https://img.shields.io/docker/image-size/bscdataclay/dspython/latest "https://hub.docker.com/repository/docker/bscdataclay/dspython/tags?name=latest&page=1"
[DSpython:layers:latest]: https://img.shields.io/microbadger/layers/bscdataclay/dspython:latest 
[DSpython:commit:latest]: https://images.microbadger.com/badges/commit/bscdataclay/dspython:latest.svg "https://microbadger.com/images/bscdataclay/dspython:latest"

[DSpython:size:2.5.py36]: https://img.shields.io/docker/image-size/bscdataclay/dspython/2.5.py36 "https://hub.docker.com/repository/docker/bscdataclay/dspython/tags?name=2.5.py36&page=1"
[DSpython:layers:2.5.py36]: https://img.shields.io/microbadger/layers/bscdataclay/dspython:2.5.py36 
[DSpython:commit:2.5.py36]: https://images.microbadger.com/badges/commit/bscdataclay/dspython:2.5.py36.svg "https://microbadger.com/images/bscdataclay/dspython:2.5.py36"

[DSpython:size:2.5.py38]: https://img.shields.io/docker/image-size/bscdataclay/dspython/2.5.py38 "https://hub.docker.com/repository/docker/bscdataclay/dspython/tags?name=2.5.py38&page=1"
[DSpython:layers:2.5.py38]: https://img.shields.io/microbadger/layers/bscdataclay/dspython:2.5.py38 
[DSpython:commit:2.5.py38]: https://images.microbadger.com/badges/commit/bscdataclay/dspython:2.5.py38.svg "https://microbadger.com/images/bscdataclay/dspython:2.5.py38"

[DSpython:size:slim]: https://img.shields.io/docker/image-size/bscdataclay/dspython/slim "https://hub.docker.com/repository/docker/bscdataclay/dspython/tags?name=slim&page=1"
[DSpython:layers:slim]: https://img.shields.io/microbadger/layers/bscdataclay/dspython:slim 
[DSpython:commit:slim]: https://images.microbadger.com/badges/commit/bscdataclay/dspython:slim.svg "https://microbadger.com/images/bscdataclay/dspython:slim"

[DSpython:size:2.5.py36-slim]: https://img.shields.io/docker/image-size/bscdataclay/dspython/2.5.py36-slim "https://hub.docker.com/repository/docker/bscdataclay/dspython/tags?name=2.5.py36-slim&page=1"
[DSpython:layers:2.5.py36-slim]: https://img.shields.io/microbadger/layers/bscdataclay/dspython:2.5.py36-slim 
[DSpython:commit:2.5.py36-slim]: https://images.microbadger.com/badges/commit/bscdataclay/dspython:2.5.py36-slim.svg "https://microbadger.com/images/bscdataclay/dspython:2.5.py36-slim"

[DSpython:size:2.5.py38-slim]: https://img.shields.io/docker/image-size/bscdataclay/dspython/2.5.py38-slim "https://hub.docker.com/repository/docker/bscdataclay/dspython/tags?name=2.5.py38-slim&page=1"
[DSpython:layers:2.5.py38-slim]: https://img.shields.io/microbadger/layers/bscdataclay/dspython:2.5.py38-slim 
[DSpython:commit:2.5.py38-slim]: https://images.microbadger.com/badges/commit/bscdataclay/dspython:2.5.py38-slim.svg "https://microbadger.com/images/bscdataclay/dspython:2.5.py38-slim"

[DSpython:size:alpine]: https://img.shields.io/docker/image-size/bscdataclay/dspython/alpine "https://hub.docker.com/repository/docker/bscdataclay/dspython/tags?name=alpine&page=1"
[DSpython:layers:alpine]: https://img.shields.io/microbadger/layers/bscdataclay/dspython:alpine 
[DSpython:commit:alpine]: https://images.microbadger.com/badges/commit/bscdataclay/dspython:alpine.svg "https://microbadger.com/images/bscdataclay/dspython:alpine"

[DSpython:size:2.5.py36-alpine]: https://img.shields.io/docker/image-size/bscdataclay/dspython/2.5.py36-alpine "https://hub.docker.com/repository/docker/bscdataclay/dspython/tags?name=2.5.py36-alpine&page=1"
[DSpython:layers:2.5.py36-alpine]: https://img.shields.io/microbadger/layers/bscdataclay/dspython:2.5.py36-alpine 
[DSpython:commit:2.5.py36-alpine]: https://images.microbadger.com/badges/commit/bscdataclay/dspython:2.5.py36-alpine.svg "https://microbadger.com/images/bscdataclay/dspython:2.5.py36-alpine"

[DSpython:size:2.5.py38-alpine]: https://img.shields.io/docker/image-size/bscdataclay/dspython/2.5.py38-alpine "https://hub.docker.com/repository/docker/bscdataclay/dspython/tags?name=2.5.py38-alpine&page=1"
[DSpython:layers:2.5.py38-alpine]: https://img.shields.io/microbadger/layers/bscdataclay/dspython:2.5.py38-alpine 
[DSpython:commit:2.5.py38-alpine]: https://images.microbadger.com/badges/commit/bscdataclay/dspython:2.5.py38-alpine.svg "https://microbadger.com/images/bscdataclay/dspython:2.5.py38-alpine"


[Client:size:latest]: https://img.shields.io/docker/image-size/bscdataclay/client/latest "https://hub.docker.com/repository/docker/bscdataclay/client/tags?name=latest&page=1"
[Client:layers:latest]: https://img.shields.io/microbadger/layers/bscdataclay/client:latest
[Client:commit:latest]: https://images.microbadger.com/badges/commit/bscdataclay/client:latest.svg "https://microbadger.com/images/bscdataclay/client:latest"

[Client:size:slim]: https://img.shields.io/docker/image-size/bscdataclay/client/slim "https://hub.docker.com/repository/docker/bscdataclay/client/tags?name=slim&page=1"
[Client:layers:slim]: https://img.shields.io/microbadger/layers/bscdataclay/client:slim
[Client:commit:slim]: https://images.microbadger.com/badges/commit/bscdataclay/client:slim.svg "https://microbadger.com/images/bscdataclay/client:slim"

[Client:size:alpine]: https://img.shields.io/docker/image-size/bscdataclay/client/alpine "https://hub.docker.com/repository/docker/bscdataclay/client/tags?name=alpine&page=1"
[Client:layers:alpine]: https://img.shields.io/microbadger/layers/bscdataclay/client:alpine
[Client:commit:alpine]: https://images.microbadger.com/badges/commit/bscdataclay/client:alpine.svg "https://microbadger.com/images/bscdataclay/client:slim"




| image                   | tags             |                                                                                 |
|-------------------------|------------------|---------------------------------------------------------------------------------|
| bscdataclay/logicmodule |   `latest` `2.5` `2.5.jdk8` |  ![LM:size:latest] ![LM:layers:latest] ![LM:commit:latest] |
|                         |   `2.5.jdk11`    |  ![LM:size:2.5.jdk11] ![LM:layers:2.5.jdk11] ![LM:commit:2.5.jdk11] |
|                         |   `slim` `2.5.jdk8-slim`    |  ![LM:size:slim] ![LM:layers:slim] ![LM:commit:slim] |
|                         |   `2.5.jdk11-slim`    |  ![LM:size:2.5.jdk11-slim] ![LM:layers:2.5.jdk11-slim] ![LM:commit:2.5.jdk11-slim]  |
|                         |   `alpine` `2.5.jdk11-alpine`    |  ![LM:size:alpine] ![LM:layers:alpine] ![LM:commit:alpine] |
| bscdataclay/dsjava |   `latest` `2.5` `2.5.jdk8` |  ![DSjava:size:latest] ![DSjava:layers:latest] ![DSjava:commit:latest] |
|                         |   `2.5.jdk11`    |  ![DSjava:size:2.5.jdk11] ![DSjava:layers:2.5.jdk11] ![DSjava:commit:2.5.jdk11] |
|                         |   `slim` `2.5.jdk8-slim`    |  ![DSjava:size:slim] ![DSjava:layers:slim] ![DSjava:commit:slim] |
|                         |   `2.5.jdk11-slim`    |  ![DSjava:size:2.5.jdk11-slim] ![DSjava:layers:2.5.jdk11-slim] ![DSjava:commit:2.5.jdk11-slim]  |
|                         |   `alpine` `2.5.jdk11-alpine`    |  ![DSjava:size:alpine] ![DSjava:layers:alpine] ![DSjava:commit:alpine] |
| bscdataclay/dspython      |   `latest` `2.5` `2.5.py37` |  ![DSpython:size:latest] ![DSpython:layers:latest] ![DSpython:commit:latest] |
|                         |   `2.5.py36`    |  ![DSpython:size:2.5.py36] ![DSpython:layers:2.5.py36] ![DSpython:commit:2.5.py36]  |
|                         |   `2.5.py38`    |  ![DSpython:size:2.5.py38] ![DSpython:layers:2.5.py38] ![DSpython:commit:2.5.py38]  |
|                         |   `slim` `2.5-slim` `2.5.py37-slim` |  ![DSpython:size:slim] ![DSpython:layers:slim] ![DSpython:commit:slim] |
|                         |   `2.5.py36`    |  ![DSpython:size:2.5.py36-slim] ![DSpython:layers:2.5.py36-slim] ![DSpython:commit:2.5.py36-slim]  |
|                         |   `2.5.py38`    |  ![DSpython:size:2.5.py38-slim] ![DSpython:layers:2.5.py38-slim] ![DSpython:commit:2.5.py38-slim]  |
|                         |   `alpine` `2.5-alpine` `2.5.py37-alpine` |  ![DSpython:size:alpine] ![DSpython:layers:alpine] ![DSpython:commit:alpine] |
|                         |   `2.5.py36`    |  ![DSpython:size:2.5.py36-alpine] ![DSpython:layers:2.5.py36-alpine] ![DSpython:commit:2.5.py36-alpine]  |
|                         |   `2.5.py38`    |  ![DSpython:size:2.5.py38-alpine] ![DSpython:layers:2.5.py38-alpine] ![DSpython:commit:2.5.py38-alpine]  |
| bscdataclay/client |   `latest` `2.5`  |  ![Client:size:latest]  ![Client:layers:latest] ![Client:commit:latest]  |
|                         |   `slim` `2.5-slim` |  ![Client:size:slim] ![Client:layers:slim] ![Client:commit:slim]  |
|                         |   `alpine` `2.5-alpine` |  ![Client:size:alpine] ![Client:layers:alpine] ![Client:commit:alpine]  |

## Documentation

Official documentation available at [read the docs](https://pyclay.readthedocs.io/en/latest/)

## Other resources

[BSC official dataClay webpage](https://www.bsc.es/dataclay)

---

![dataClay logo](https://www.bsc.es/sites/default/files/public/styles/bscw2_-_simple_crop_style/public/bscw2/content/software-app/logo/logo_dataclay_web_bsc.jpg)

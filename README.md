[![License](https://img.shields.io/github/license/bsc-dom/dataclay-packaging)](https://github.com/bsc-dom/dataclay-packaging/blob/develop/LICENSE.txt)

# dataClay packaging

This repository holds everything needed to deploy dataClay using
containers (docker and singularity) in multiple architectures

<img src="https://img.shields.io/badge/docker%20-%230db7ed.svg?&style=for-the-badge&logo=docker&logoColor=white"/><br/>


[LM:size:develop]: https://img.shields.io/docker/image-size/bscdataclay/logicmodule/develop "https://hub.docker.com/repository/docker/bscdataclay/logicmodule/tags?name=develop&page=1"
[LM:layers:develop]: https://img.shields.io/microbadger/layers/bscdataclay/logicmodule:develop 
[LM:commit:develop]: https://images.microbadger.com/badges/commit/bscdataclay/logicmodule:develop.svg "https://microbadger.com/images/bscdataclay/logicmodule:develop"

[LM:size:2.5.jdk11.dev]: https://img.shields.io/docker/image-size/bscdataclay/logicmodule/2.5.jdk11.dev "https://hub.docker.com/repository/docker/bscdataclay/logicmodule/tags?name=2.5.jdk11.dev&page=1"
[LM:layers:2.5.jdk11.dev]: https://img.shields.io/microbadger/layers/bscdataclay/logicmodule:2.5.jdk11.dev 
[LM:commit:2.5.jdk11.dev]: https://images.microbadger.com/badges/commit/bscdataclay/logicmodule:2.5.jdk11.dev.svg "https://microbadger.com/images/bscdataclay/logicmodule:2.5.jdk11.dev"

[LM:size:develop-slim]: https://img.shields.io/docker/image-size/bscdataclay/logicmodule/develop-slim "https://hub.docker.com/repository/docker/bscdataclay/logicmodule/tags?name=develop-slim&page=1"
[LM:layers:develop-slim]: https://img.shields.io/microbadger/layers/bscdataclay/logicmodule:develop-slim 
[LM:commit:develop-slim]: https://images.microbadger.com/badges/commit/bscdataclay/logicmodule:develop-slim.svg "https://microbadger.com/images/bscdataclay/logicmodule:develop-slim"

[LM:size:2.5.jdk11.dev-slim]: https://img.shields.io/docker/image-size/bscdataclay/logicmodule/2.5.jdk11.dev-slim "https://hub.docker.com/repository/docker/bscdataclay/logicmodule/tags?name=2.5.jdk11.dev-slim&page=1"
[LM:layers:2.5.jdk11.dev-slim]: https://img.shields.io/microbadger/layers/bscdataclay/logicmodule:2.5.jdk11.dev-slim 
[LM:commit:2.5.jdk11.dev-slim]: https://images.microbadger.com/badges/commit/bscdataclay/logicmodule:2.5.jdk11.dev-slim.svg "https://microbadger.com/images/bscdataclay/logicmodule:2.5.jdk11.dev-slim"

[LM:size:develop-alpine]: https://img.shields.io/docker/image-size/bscdataclay/logicmodule/develop-alpine "https://hub.docker.com/repository/docker/bscdataclay/logicmodule/tags?name=develop-alpine&page=1"
[LM:layers:develop-alpine]: https://img.shields.io/microbadger/layers/bscdataclay/logicmodule:develop-alpine 
[LM:commit:develop-alpine]: https://images.microbadger.com/badges/commit/bscdataclay/logicmodule:develop-alpine.svg "https://microbadger.com/images/bscdataclay/logicmodule:develop-alpine"

[DSjava:size:develop]: https://img.shields.io/docker/image-size/bscdataclay/dsjava/develop "https://hub.docker.com/repository/docker/bscdataclay/dsjava/tags?name=develop&page=1"
[DSjava:layers:develop]: https://img.shields.io/microbadger/layers/bscdataclay/dsjava:develop 
[DSjava:commit:develop]: https://images.microbadger.com/badges/commit/bscdataclay/dsjava:develop.svg "https://microbadger.com/images/bscdataclay/dsjava:develop"

[DSjava:size:2.5.jdk11.dev]: https://img.shields.io/docker/image-size/bscdataclay/dsjava/2.5.jdk11.dev "https://hub.docker.com/repository/docker/bscdataclay/dsjava/tags?name=2.5.jdk11.dev&page=1"
[DSjava:layers:2.5.jdk11.dev]: https://img.shields.io/microbadger/layers/bscdataclay/dsjava:2.5.jdk11.dev 
[DSjava:commit:2.5.jdk11.dev]: https://images.microbadger.com/badges/commit/bscdataclay/dsjava:2.5.jdk11.dev.svg "https://microbadger.com/images/bscdataclay/dsjava:2.5.jdk11.dev"

[DSjava:size:develop-slim]: https://img.shields.io/docker/image-size/bscdataclay/dsjava/develop-slim "https://hub.docker.com/repository/docker/bscdataclay/dsjava/tags?name=develop-slim&page=1"
[DSjava:layers:develop-slim]: https://img.shields.io/microbadger/layers/bscdataclay/dsjava:develop-slim 
[DSjava:commit:develop-slim]: https://images.microbadger.com/badges/commit/bscdataclay/dsjava:develop-slim.svg "https://microbadger.com/images/bscdataclay/dsjava:develop-slim"

[DSjava:size:2.5.jdk11.dev-slim]: https://img.shields.io/docker/image-size/bscdataclay/dsjava/2.5.jdk11.dev-slim "https://hub.docker.com/repository/docker/bscdataclay/dsjava/tags?name=2.5.jdk11.dev-slim&page=1"
[DSjava:layers:2.5.jdk11.dev-slim]: https://img.shields.io/microbadger/layers/bscdataclay/dsjava:2.5.jdk11.dev-slim 
[DSjava:commit:2.5.jdk11.dev-slim]: https://images.microbadger.com/badges/commit/bscdataclay/dsjava:2.5.jdk11.dev-slim.svg "https://microbadger.com/images/bscdataclay/dsjava:2.5.jdk11.dev-slim"

[DSjava:size:develop-alpine]: https://img.shields.io/docker/image-size/bscdataclay/dsjava/develop-alpine "https://hub.docker.com/repository/docker/bscdataclay/dsjava/tags?name=develop-alpine&page=1"
[DSjava:layers:develop-alpine]: https://img.shields.io/microbadger/layers/bscdataclay/dsjava:develop-alpine 
[DSjava:commit:develop-alpine]: https://images.microbadger.com/badges/commit/bscdataclay/dsjava:develop-alpine.svg "https://microbadger.com/images/bscdataclay/dsjava:develop-alpine"

[DSpython:size:develop]: https://img.shields.io/docker/image-size/bscdataclay/dspython/develop "https://hub.docker.com/repository/docker/bscdataclay/dspython/tags?name=develop&page=1"
[DSpython:layers:develop]: https://img.shields.io/microbadger/layers/bscdataclay/dspython:develop 
[DSpython:commit:develop]: https://images.microbadger.com/badges/commit/bscdataclay/dspython:develop.svg "https://microbadger.com/images/bscdataclay/dspython:develop"

[DSpython:size:2.5.py36.dev]: https://img.shields.io/docker/image-size/bscdataclay/dspython/2.5.py36.dev "https://hub.docker.com/repository/docker/bscdataclay/dspython/tags?name=2.5.py36.dev&page=1"
[DSpython:layers:2.5.py36.dev]: https://img.shields.io/microbadger/layers/bscdataclay/dspython:2.5.py36.dev 
[DSpython:commit:2.5.py36.dev]: https://images.microbadger.com/badges/commit/bscdataclay/dspython:2.5.py36.dev.svg "https://microbadger.com/images/bscdataclay/dspython:2.5.py36.dev"

[DSpython:size:2.5.py38.dev]: https://img.shields.io/docker/image-size/bscdataclay/dspython/2.5.py38.dev "https://hub.docker.com/repository/docker/bscdataclay/dspython/tags?name=2.5.py38.dev&page=1"
[DSpython:layers:2.5.py38.dev]: https://img.shields.io/microbadger/layers/bscdataclay/dspython:2.5.py38.dev 
[DSpython:commit:2.5.py38.dev]: https://images.microbadger.com/badges/commit/bscdataclay/dspython:2.5.py38.dev.svg "https://microbadger.com/images/bscdataclay/dspython:2.5.py38.dev"

[DSpython:size:develop-slim]: https://img.shields.io/docker/image-size/bscdataclay/dspython/develop-slim "https://hub.docker.com/repository/docker/bscdataclay/dspython/tags?name=develop-slim&page=1"
[DSpython:layers:develop-slim]: https://img.shields.io/microbadger/layers/bscdataclay/dspython:develop-slim 
[DSpython:commit:develop-slim]: https://images.microbadger.com/badges/commit/bscdataclay/dspython:develop-slim.svg "https://microbadger.com/images/bscdataclay/dspython:develop-slim"

[DSpython:size:2.5.py36.dev-slim]: https://img.shields.io/docker/image-size/bscdataclay/dspython/2.5.py36.dev-slim "https://hub.docker.com/repository/docker/bscdataclay/dspython/tags?name=2.5.py36.dev-slim&page=1"
[DSpython:layers:2.5.py36.dev-slim]: https://img.shields.io/microbadger/layers/bscdataclay/dspython:2.5.py36.dev-slim 
[DSpython:commit:2.5.py36.dev-slim]: https://images.microbadger.com/badges/commit/bscdataclay/dspython:2.5.py36.dev-slim.svg "https://microbadger.com/images/bscdataclay/dspython:2.5.py36.dev-slim"

[DSpython:size:2.5.py38.dev-slim]: https://img.shields.io/docker/image-size/bscdataclay/dspython/2.5.py38.dev-slim "https://hub.docker.com/repository/docker/bscdataclay/dspython/tags?name=2.5.py38.dev-slim&page=1"
[DSpython:layers:2.5.py38.dev-slim]: https://img.shields.io/microbadger/layers/bscdataclay/dspython:2.5.py38.dev-slim 
[DSpython:commit:2.5.py38.dev-slim]: https://images.microbadger.com/badges/commit/bscdataclay/dspython:2.5.py38.dev-slim.svg "https://microbadger.com/images/bscdataclay/dspython:2.5.py38.dev-slim"

[DSpython:size:develop-alpine]: https://img.shields.io/docker/image-size/bscdataclay/dspython/develop-alpine "https://hub.docker.com/repository/docker/bscdataclay/dspython/tags?name=develop-alpine&page=1"
[DSpython:layers:develop-alpine]: https://img.shields.io/microbadger/layers/bscdataclay/dspython:develop-alpine 
[DSpython:commit:develop-alpine]: https://images.microbadger.com/badges/commit/bscdataclay/dspython:develop-alpine.svg "https://microbadger.com/images/bscdataclay/dspython:develop-alpine"

[DSpython:size:2.5.py36.dev-alpine]: https://img.shields.io/docker/image-size/bscdataclay/dspython/2.5.py36.dev-alpine "https://hub.docker.com/repository/docker/bscdataclay/dspython/tags?name=2.5.py36.dev-alpine&page=1"
[DSpython:layers:2.5.py36.dev-alpine]: https://img.shields.io/microbadger/layers/bscdataclay/dspython:2.5.py36.dev-alpine 
[DSpython:commit:2.5.py36.dev-alpine]: https://images.microbadger.com/badges/commit/bscdataclay/dspython:2.5.py36.dev-alpine.svg "https://microbadger.com/images/bscdataclay/dspython:2.5.py36.dev-alpine"

[DSpython:size:2.5.py38.dev-alpine]: https://img.shields.io/docker/image-size/bscdataclay/dspython/2.5.py38.dev-alpine "https://hub.docker.com/repository/docker/bscdataclay/dspython/tags?name=2.5.py38.dev-alpine&page=1"
[DSpython:layers:2.5.py38.dev-alpine]: https://img.shields.io/microbadger/layers/bscdataclay/dspython:2.5.py38.dev-alpine 
[DSpython:commit:2.5.py38.dev-alpine]: https://images.microbadger.com/badges/commit/bscdataclay/dspython:2.5.py38.dev-alpine.svg "https://microbadger.com/images/bscdataclay/dspython:2.5.py38.dev-alpine"


[Client:size:develop]: https://img.shields.io/docker/image-size/bscdataclay/client/develop "https://hub.docker.com/repository/docker/bscdataclay/client/tags?name=develop&page=1"
[Client:layers:develop]: https://img.shields.io/microbadger/layers/bscdataclay/client:develop
[Client:commit:develop]: https://images.microbadger.com/badges/commit/bscdataclay/client:develop.svg "https://microbadger.com/images/bscdataclay/client:develop"

[Client:size:develop-slim]: https://img.shields.io/docker/image-size/bscdataclay/client/develop-slim "https://hub.docker.com/repository/docker/bscdataclay/client/tags?name=develop-slim&page=1"
[Client:layers:develop-slim]: https://img.shields.io/microbadger/layers/bscdataclay/client:develop-slim
[Client:commit:develop-slim]: https://images.microbadger.com/badges/commit/bscdataclay/client:develop-slim.svg "https://microbadger.com/images/bscdataclay/client:develop-slim"

[Client:size:develop-alpine]: https://img.shields.io/docker/image-size/bscdataclay/client/develop-alpine "https://hub.docker.com/repository/docker/bscdataclay/client/tags?name=develop-alpine&page=1"
[Client:layers:develop-alpine]: https://img.shields.io/microbadger/layers/bscdataclay/client:develop-alpine
[Client:commit:develop-alpine]: https://images.microbadger.com/badges/commit/bscdataclay/client:develop-alpine.svg "https://microbadger.com/images/bscdataclay/client:develop-slim"




| image                   | tags             |                                                                                 |
|-------------------------|------------------|---------------------------------------------------------------------------------|
| bscdataclay/logicmodule |   `develop` `2.5.dev` `2.5.jdk8.dev` |  ![LM:size:develop] ![LM:layers:develop] ![LM:commit:develop] |
|                         |   `2.5.jdk11.dev`    |  ![LM:size:2.5.jdk11.dev] ![LM:layers:2.5.jdk11.dev] ![LM:commit:2.5.jdk11.dev] |
|                         |   `develop-slim` `2.5.jdk8.dev-slim`    |  ![LM:size:develop-slim] ![LM:layers:develop-slim] ![LM:commit:develop-slim] |
|                         |   `2.5.jdk11.dev-slim`    |  ![LM:size:2.5.jdk11.dev-slim] ![LM:layers:2.5.jdk11.dev-slim] ![LM:commit:2.5.jdk11.dev-slim]  |
|                         |   `develop-alpine` `2.5.jdk11.dev-alpine`    |  ![LM:size:develop-alpine] ![LM:layers:develop-alpine] ![LM:commit:develop-alpine] |
| bscdataclay/dsjava |   `develop` `2.5.dev` `2.5.jdk8.dev` |  ![DSjava:size:develop] ![DSjava:layers:develop] ![DSjava:commit:develop] |
|                         |   `2.5.jdk11.dev`    |  ![DSjava:size:2.5.jdk11.dev] ![DSjava:layers:2.5.jdk11.dev] ![DSjava:commit:2.5.jdk11.dev] |
|                         |   `develop-slim` `2.5.jdk8.dev-slim`    |  ![DSjava:size:develop-slim] ![DSjava:layers:develop-slim] ![DSjava:commit:develop-slim] |
|                         |   `2.5.jdk11.dev-slim`    |  ![DSjava:size:2.5.jdk11.dev-slim] ![DSjava:layers:2.5.jdk11.dev-slim] ![DSjava:commit:2.5.jdk11.dev-slim]  |
|                         |   `develop-alpine` `2.5.jdk11.dev-alpine`    |  ![DSjava:size:develop-alpine] ![DSjava:layers:develop-alpine] ![DSjava:commit:develop-alpine] |
| bscdataclay/dspython      |   `develop` `2.5.dev` `2.5.py37.dev` |  ![DSpython:size:develop] ![DSpython:layers:develop] ![DSpython:commit:develop] |
|                         |   `2.5.py36.dev`    |  ![DSpython:size:2.5.py36.dev] ![DSpython:layers:2.5.py36.dev] ![DSpython:commit:2.5.py36.dev]  |
|                         |   `2.5.py38.dev`    |  ![DSpython:size:2.5.py38.dev] ![DSpython:layers:2.5.py38.dev] ![DSpython:commit:2.5.py38.dev]  |
|                         |   `develop-slim` `2.5.dev-slim` `2.5.py37.dev-slim` |  ![DSpython:size:develop-slim] ![DSpython:layers:develop-slim] ![DSpython:commit:develop-slim] |
|                         |   `2.5.py36.dev`    |  ![DSpython:size:2.5.py36.dev-slim] ![DSpython:layers:2.5.py36.dev-slim] ![DSpython:commit:2.5.py36.dev-slim]  |
|                         |   `2.5.py38.dev`    |  ![DSpython:size:2.5.py38.dev-slim] ![DSpython:layers:2.5.py38.dev-slim] ![DSpython:commit:2.5.py38.dev-slim]  |
|                         |   `develop-alpine` `2.5.dev-alpine` `2.5.py37.dev-alpine` |  ![DSpython:size:develop-alpine] ![DSpython:layers:develop-alpine] ![DSpython:commit:develop-alpine] |
|                         |   `2.5.py36.dev`    |  ![DSpython:size:2.5.py36.dev-alpine] ![DSpython:layers:2.5.py36.dev-alpine] ![DSpython:commit:2.5.py36.dev-alpine]  |
|                         |   `2.5.py38.dev`    |  ![DSpython:size:2.5.py38.dev-alpine] ![DSpython:layers:2.5.py38.dev-alpine] ![DSpython:commit:2.5.py38.dev-alpine]  |
| bscdataclay/client |   `develop` `2.5.dev`  |  ![Client:size:develop]  ![Client:layers:develop] ![Client:commit:develop]  |
|                         |   `develop-slim` `2.5.dev-slim` |  ![Client:size:develop-slim] ![Client:layers:develop-slim] ![Client:commit:develop-slim]  |
|                         |   `develop-alpine` `2.5.dev-alpine` |  ![Client:size:develop-alpine] ![Client:layers:develop-alpine] ![Client:commit:develop-alpine]  |

## Documentation

Official documentation available at [read the docs](https://pyclay.readthedocs.io/en/latest/)

## Other resources

[BSC official dataClay webpage](https://www.bsc.es/dataclay)

---

![dataClay logo](https://www.bsc.es/sites/default/files/public/styles/bscw2_-_simple_crop_style/public/bscw2/content/software-app/logo/logo_dataclay_web_bsc.jpg)

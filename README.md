[![License](https://img.shields.io/github/license/bsc-dom/dataclay-packaging)](https://github.com/bsc-dom/dataclay-packaging/blob/develop/LICENSE.txt)
[![Build status](https://ci.appveyor.com/api/projects/status/kugl74xd5aq6pubr/branch/develop?svg=true)](https://ci.appveyor.com/project/support-dataclay/dataclay-packaging-as6o1/branch/develop)


# dataClay packaging

This repository holds everything needed to deploy dataClay using
containers (docker and singularity) in multiple architectures

Singularity images are build from normal dataClay docker images (not slim or alpine)

BSC Extrae Tracing is not available in Slim and Alpine images.

Alpine images are only available in JDK 11 due to gRPC-SSL security issues.

<img src="https://img.shields.io/badge/docker%20-%230db7ed.svg?&style=for-the-badge&logo=docker&logoColor=white"/><br/>


[LM:size:develop]: https://img.shields.io/docker/image-size/bscdataclay/logicmodule/develop "https://hub.docker.com/repository/docker/bscdataclay/logicmodule/tags?name=develop&page=1"

[LM:size:2.7.jdk11.dev]: https://img.shields.io/docker/image-size/bscdataclay/logicmodule/2.7.jdk11.dev "https://hub.docker.com/repository/docker/bscdataclay/logicmodule/tags?name=2.7.jdk11.dev&page=1"

[LM:size:develop-slim]: https://img.shields.io/docker/image-size/bscdataclay/logicmodule/develop-slim "https://hub.docker.com/repository/docker/bscdataclay/logicmodule/tags?name=slim&page=1"

[LM:size:2.7.jdk11.dev-slim]: https://img.shields.io/docker/image-size/bscdataclay/logicmodule/2.7.jdk11.dev-slim "https://hub.docker.com/repository/docker/bscdataclay/logicmodule/tags?name=2.7.jdk11.dev-slim&page=1"

[LM:size:develop-alpine]: https://img.shields.io/docker/image-size/bscdataclay/logicmodule/develop-alpine "https://hub.docker.com/repository/docker/bscdataclay/logicmodule/tags?name=alpine&page=1"

[DSjava:size:develop]: https://img.shields.io/docker/image-size/bscdataclay/dsjava/develop "https://hub.docker.com/repository/docker/bscdataclay/dsjava/tags?name=develop&page=1"

[DSjava:size:2.7.jdk11.dev]: https://img.shields.io/docker/image-size/bscdataclay/dsjava/2.7.jdk11.dev "https://hub.docker.com/repository/docker/bscdataclay/dsjava/tags?name=2.7.jdk11.dev&page=1"

[DSjava:size:develop-slim]: https://img.shields.io/docker/image-size/bscdataclay/dsjava/develop-slim "https://hub.docker.com/repository/docker/bscdataclay/dsjava/tags?name=slim&page=1"

[DSjava:size:2.7.jdk11.dev-slim]: https://img.shields.io/docker/image-size/bscdataclay/dsjava/2.7.jdk11.dev-slim "https://hub.docker.com/repository/docker/bscdataclay/dsjava/tags?name=2.7.jdk11.dev-slim&page=1"

[DSjava:size:develop-alpine]: https://img.shields.io/docker/image-size/bscdataclay/dsjava/develop-alpine "https://hub.docker.com/repository/docker/bscdataclay/dsjava/tags?name=alpine&page=1"

[DSpython:size:develop]: https://img.shields.io/docker/image-size/bscdataclay/dspython/develop "https://hub.docker.com/repository/docker/bscdataclay/dspython/tags?name=develop&page=1"

[DSpython:size:2.7.py36.dev]: https://img.shields.io/docker/image-size/bscdataclay/dspython/2.7.py36.dev "https://hub.docker.com/repository/docker/bscdataclay/dspython/tags?name=2.7.py36.dev&page=1"

[DSpython:size:2.7.py38.dev]: https://img.shields.io/docker/image-size/bscdataclay/dspython/2.7.py38.dev "https://hub.docker.com/repository/docker/bscdataclay/dspython/tags?name=2.7.py38.dev&page=1"

[DSpython:size:develop-slim]: https://img.shields.io/docker/image-size/bscdataclay/dspython/develop-slim "https://hub.docker.com/repository/docker/bscdataclay/dspython/tags?name=slim&page=1"

[DSpython:size:2.7.py36.dev-slim]: https://img.shields.io/docker/image-size/bscdataclay/dspython/2.7.py36.dev-slim "https://hub.docker.com/repository/docker/bscdataclay/dspython/tags?name=2.7.py36.dev-slim&page=1"

[DSpython:size:2.7.py38.dev-slim]: https://img.shields.io/docker/image-size/bscdataclay/dspython/2.7.py38.dev-slim "https://hub.docker.com/repository/docker/bscdataclay/dspython/tags?name=2.7.py38.dev-slim&page=1"

[DSpython:size:develop-alpine]: https://img.shields.io/docker/image-size/bscdataclay/dspython/develop-alpine "https://hub.docker.com/repository/docker/bscdataclay/dspython/tags?name=alpine&page=1"

[DSpython:size:2.7.py36.dev-alpine]: https://img.shields.io/docker/image-size/bscdataclay/dspython/2.7.py36.dev-alpine "https://hub.docker.com/repository/docker/bscdataclay/dspython/tags?name=2.7.py36.dev-alpine&page=1"

[DSpython:size:2.7.py38.dev-alpine]: https://img.shields.io/docker/image-size/bscdataclay/dspython/2.7.py38.dev-alpine "https://hub.docker.com/repository/docker/bscdataclay/dspython/tags?name=2.7.py38.dev-alpine&page=1"

[Client:size:develop]: https://img.shields.io/docker/image-size/bscdataclay/client/develop "https://hub.docker.com/repository/docker/bscdataclay/client/tags?name=develop&page=1"

[Client:size:develop-slim]: https://img.shields.io/docker/image-size/bscdataclay/client/develop-slim "https://hub.docker.com/repository/docker/bscdataclay/client/tags?name=slim&page=1"

[Client:size:develop-alpine]: https://img.shields.io/docker/image-size/bscdataclay/client/develop-alpine "https://hub.docker.com/repository/docker/bscdataclay/client/tags?name=alpine&page=1"




| image                   | tags             |                                                                                 |
|-------------------------|------------------|---------------------------------------------------------------------------------|
| bscdataclay/logicmodule |   `develop` `2.7` `2.7.jdk8.dev` |  ![LM:size:develop] |
|                         |   `2.7.jdk11.dev`    |  ![LM:size:2.7.jdk11.dev] |
|                         |   `develop-slim` `2.7.jdk8.dev-slim`    |  ![LM:size:develop-slim] |
|                         |   `2.7.jdk11.dev-slim`    |  ![LM:size:2.7.jdk11.dev-slim]  |
|                         |   `develop-alpine` `2.7.jdk11.dev-alpine`    |  ![LM:size:develop-alpine] |
| bscdataclay/dsjava |   `develop` `2.7` `2.7.jdk8.dev` |  ![DSjava:size:develop] |
|                         |   `2.7.jdk11.dev`    |  ![DSjava:size:2.7.jdk11.dev] |
|                         |   `develop-slim` `2.7.jdk8.dev-slim`    |  ![DSjava:size:develop-slim] |
|                         |   `2.7.jdk11.dev-slim`    |  ![DSjava:size:2.7.jdk11.dev-slim] |
|                         |   `develop-alpine` `2.7.jdk11.dev-alpine`    |  ![DSjava:size:develop-alpine] |
| bscdataclay/dspython      |   `develop` `2.7` `2.7.py37.dev` |  ![DSpython:size:develop] |
|                         |   `2.7.py36.dev`    |  ![DSpython:size:2.7.py36.dev]  |
|                         |   `2.7.py38.dev`    |  ![DSpython:size:2.7.py38.dev]  |
|                         |   `develop-slim` `2.7-slim` `2.7.py37.dev-slim` |  ![DSpython:size:develop-slim] |
|                         |   `2.7.py36.dev-slim`    |  ![DSpython:size:2.7.py36.dev-slim] |
|                         |   `2.7.py38.dev-slim`    |  ![DSpython:size:2.7.py38.dev-slim] |
|                         |   `develop-alpine` `2.7-alpine` `2.7.py37.dev-alpine` |  ![DSpython:size:develop-alpine] |
|                         |   `2.7.py36.dev-alpine`    |  ![DSpython:size:2.7.py36.dev-alpine] |
|                         |   `2.7.py38.dev-alpine`    |  ![DSpython:size:2.7.py38.dev-alpine] |
| bscdataclay/client |   `develop` `2.7`  |  ![Client:size:develop] |
|                         |   `develop-slim` `2.7-slim` |  ![Client:size:develop-slim] |
|                         |   `develop-alpine` `2.7-alpine` |  ![Client:size:develop-alpine]  |

## Documentation

Official documentation available at [read the docs](https://pyclay.readthedocs.io/en/develop/)

## Other resources

[BSC official dataClay webpage](https://www.bsc.es/dataclay)

---

![dataClay logo](https://www.bsc.es/sites/default/files/public/styles/bscw2_-_simple_crop_style/public/bscw2/content/software-app/logo/logo_dataclay_web_bsc.jpg)

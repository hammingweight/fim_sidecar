# Containers
This repository contains Dockerfiles for two containers:
* An application container that exposes a "Hello, world" service
* A sidecar container that monitors the file integrity of the application container

## Application Container
This container runs a Python `SimpleHTTPServer` that exposes a single [HTML page](./index.html) that displays "Hello, world!".
The container is run as a non-root user, `hellouser`.

## Sidecar Container
The sidecar container monitors the integrity of the application's [index.html](./index.html) page. The container is run as the `root` user since elevated privileges
are needed to access arbitrary files in the application container. The file integrity checking is performed by the [`healthz`](./healthz) script. The script expects
to be passed the path to a file in the application container and the MD5 hash of the file contents.

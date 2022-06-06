# Containers
This repository contains Dockerfiles for two containers:
* An application container that exposes a "Hello, world" service
* A sidecar container that monitors the file integrity of the application container

## Application Container
The application (`hello_server`) container runs a Python `SimpleHTTPServer` that exposes a single [HTML page](./hello_server/index.html) that displays "Hello, world!".
The container is run as a non-root user, `hellouser`.

## Sidecar Container
The sidecar (`fim`) container monitors the integrity of the application's [index.html](./hello_server/index.html) page. The container is run as the `root` user since elevated
privileges are needed to access arbitrary files in the application container. The file integrity checking is performed by the [`healthz`](./fim/healthz) script. The
script expects to be passed the path to a file in the application container and the MD5 hash of the file contents. If the hash of the file contents does not match the
expected hash, the script terminates all processes in the application container.

The `healthz` script does a process listing (`ps aux`) to find processes that are running in the application container. Listing the processes will return processes
running in both the application and sidecar containers. To determine which processes are running in the sidecar, the script creates a touchfile in the sidecar
container and then looks for the touchfile in the `procfs` virtual filesystem. File paths that include the file are associated with processes and PIDs running in
the sidecar container. If the touchfile cannot be found, the associated process PID must be for a process running in the application container. Once a PID is found for
a process running in the application container, the `healthz` script can locate any file in the application container by starting at the root path `/proc/<PID>/root`
which is a symlink to the root of the application container's filepath.

Killing all processes in the application container, crashes the container and the Kubernetes scheduler will then restart the container from a clean image.

The `fim` container is built from the `busybox` base container which does not have a `bash` shell. If you want to interact with this container, you should run `ash`.

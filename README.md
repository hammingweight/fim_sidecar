# A Kubernetes File Integrity Monitoring (FIM) Sidecar Demo
A proof of concept project that shows how a Kubernetes sidecar can monitor the file integrity of another container. The purpose of this project isn't to
provide production quality code; it's simply to show that it is possible to have a sidecar container monitor the file integrity of another container and to
take remedial action if a container is hacked.

## Prerequisites
You'll need to have a local installation of [Docker](https://docker.com) and [minikube](https://minikube.sigs.k8s.io/docs/start/).

## The Basic Example
The code creates a Kubernetes pod that delivers a single HTML page with a "Hello, world!" message. The pod contains a second (sidecar) container that 
checks whether the contents of the HTML page has been edited and, if so, kills the processes running in the first container and relies on the Kubernetes
controlplane to start a new instance of the container. The pod is exposed to the outside world by a LoadBalancer service.

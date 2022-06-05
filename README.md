# A Kubernetes File Integrity Monitoring Sidecar Demo
A proof of concept project that shows how a Kubernetes sidecar can monitor the file integrity of another container. The purpose of this project isn't to
provide production quality code; it's simply to show that it is possible to have a sidecar container monitor the file integrity of another container and to
take remedial action if a container is hacked.

## Container and Pod Security
There are many mechanisms to increase the security of applications deployed in containers such as:
 * namespaces to isolate containers
 * Linux capabilities to restrict what a container can do
 * seccomp profiles to provide fine-grained access to kernel calls
 * cgroups to limit the blast radius of a denial of service attack on a single container

Despite all the security primitives available to secure containers, it can be advisable to run file intrusion monitoring (FIM) software such as
[AIDE]( https://aide.github.io/). However, an attacker who compromises a container might also be able to disable the FIM. This repository shows one way in which a
sidecar can monitor the file integrity of another container.

The containers in a pod share the same network namespace (so they share IP addresses and network connections) and UTS namespace (so they have the same hostname).
By default, pods do not share the same process namespace. The pod's containers obviously have distinct file systems. However, if two containers share the same process
namespace it is possible to allow them access to each other's file systems via the `procfs` system as noted on the 
[Kubernetes website](https://kubernetes.io/docs/tasks/configure-pod-container/share-process-namespace/). This demo shows a simple example of FIM using a sidecae
that shares a process namespace with another container.

## The Example
The code creates a Kubernetes pod that delivers a single HTML page with a "Hello, world!" message. The pod contains a second (sidecar) container that 
checks whether the contents of the HTML page has been edited and, if so, kills the processes running in the first container and relies on the Kubernetes
controlplane to start a new instance of the container. The pod is exposed to the outside world by a LoadBalancer service.

### Prequisites
You'll need locally installed versions of
 * Docker
 * Minikube


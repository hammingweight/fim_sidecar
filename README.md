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

Despite all the security primitives, it may still be advisable to run file intrusion monitoring (FIM) software such as
[AIDE]( https://aide.github.io/). However, an attacker who compromises a container might also be able to disable the FIM. This repository shows one way in which a
sidecar can monitor the file integrity of another container.

The containers in a pod share the same network namespace (so they share IP addresses and network connections) and UTS namespace (so they have the same hostname).
By default, pods do not share the same process namespace. The pod's containers obviously have distinct file systems. However, if two containers share the same process
namespace it is possible to allow them access to each other's file systems via the `procfs` system as noted in the 
[Kubernetes documentation](https://kubernetes.io/docs/tasks/configure-pod-container/share-process-namespace/). This demo shows an artificially simple example of FIM
using a sidecar container that shares a process namespace with an application container. The sidecar runs with greater privileges than the application container;
the sidecar can access files in the application container but the application cannot read files in the sidecar container. 

## The Example Application
The code creates a Kubernetes pod that delivers a single HTML page with a "Hello, world!" message. The pod contains a second (sidecar) container that 
checks whether the contents of the HTML page has been edited and, if so, kills the processes running in the first container and relies on the Kubernetes
controlplane to start a new instance of the container. The pod is exposed to the outside world by a LoadBalancer service.

### Prerequisites
You'll need locally installed versions of
 * Docker
 * Minikube

### Building and Running the Application
To build and run the application, execute

```
$ ./build.sh
```

The build script starts up minikube, builds the container images for the application and sidecar, creates a pod with the two containers and creates a Kubernetes
load balancer service to make the application accessible. If the build script completes successfully, you should be able to see the pod as running and that
the pod contains two containers.

```
$ kubectl get pods
NAME          READY   STATUS    RESTARTS   AGE
helloserver   2/2     Running   0          10s
```

Create a tunnel to access the minikube cluster

```
$ minikube tunnel
```

You should then be able to access the `helloservice` via its external IP address

```
$ kubectl get services
NAME           TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)        AGE
helloservice   LoadBalancer   10.111.46.161   10.111.46.161   80:32469/TCP   2m30s
kubernetes     ClusterIP      10.96.0.1       <none>          443/TCP        3m58s
$ curl http://10.111.46.161
Hello, world!
```

Now, set a watch on the pods

```
$ kubectl get pods -w
NAME          READY   STATUS    RESTARTS   AGE
helloserver   2/2     Running   0          5m26s
```

Next, in another terminal, modify the `index.html` page in the `helloserver` application container (which is in the `helloserver` pod)

```
$ kubectl exec -it helloserver -c helloserver -- bash
hellouser@helloserver:~$ echo hacked > index.html && exit
exit
```

The terminal showing the state of the pod should show the pod go into error and then get restarted.

```
$ kubectl get pods -w
NAME          READY   STATUS    RESTARTS   AGE
helloserver   2/2     Running   0          5m26s
helloserver   1/2     Error     0          6m21s
helloserver   2/2     Running   1 (2s ago)   6m22s
```

Issuing a `GET` should return the "Hello, world!" message again since the container was restarted.

```
$ curl http://10.111.46.161
Hello, world!
```

## How does this work?
### Accessing files via `procfs`
To see how this works, get an `ash` shell to the `fim` container in the `helloserver` pod and list the processes.

```
$ kubectl exec -it helloserver -c fim -- ash
/ # ps aux
PID   USER     TIME  COMMAND
    1 65535     0:00 /pause
    7 1000      0:00 python -m SimpleHTTPServer
   13 root      0:00 sleep infinity
  531 root      0:00 ash
  563 root      0:00 ps aux
```

The `ash` process, for example, is running within the `fim` container but the `SimpleHTTPServer` with PID 7 is running in the `helloserver` container.
Since the `fim` container is running with elevated privileges, we can access files on the `helloserver` container via symlinks in the `procfs` filesystem.
Since the PID is 7, we can access the `index.html` file by running

```
/ # cat /proc/7/root/home/hellouser/index.html
Hello, world!
```

We can try a similar experiment in the `helloserver` container by opening a `bash` shell

```
$ kubectl exec -it helloserver -c helloserver -- bash
hellouser@helloserver:~$ ps aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
65535          1  0.0  0.0    972     4 ?        Ss   10:00   0:00 /pause
hellous+       7  0.0  0.1  19168 13512 ?        Ss   10:00   0:00 python -m SimpleHTTPServer
root          13  0.0  0.0   1316     4 ?        Ss   10:00   0:00 sleep infinity
hellous+    3138  1.0  0.0   5756  3704 pts/0    Ss   10:20   0:00 bash
hellous+    3146  0.0  0.0   9396  3008 pts/0    R+   10:20   0:00 ps aux
```

Process 13 is running in the `fim` container but, this time, we cannot access the files since the `helloserver` container is not running with elevated
privileges

```
hellouser@helloserver:~$ ls /proc/13/root
ls: cannot access '/proc/13/root': Permission denied
```

### Checking file integrity as a liveness check
By default, Kubernetes polls containers for their liveness every 5 seconds. The `fim` container is configured to invoke the [`healthz`](./containers/fim/healthz)
script. This is a very simple script that takes a file name and an MD5 hash value as arguments and checks that the file contents has the expected hash.
If the hashes don't match, the script (with a certain amount of hackery) determines all the processes running in the monitored container and issues a
`SIGKILL` to all the processes. Killing all the processes in that way crashes the container and Kubernetes restarts a new instance of the container.

Two observations are in order:
* The `healthz` integrity test is minimalist; we should be checking entire directories not just a single file. Running `AIDE` in the `fim` container would be better than performing a simple hash.
* While we invoke the integrity test as a liveness check, we could run our integrity testing in a loop in the `fim` container's main process.

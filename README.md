# A File Integrity Monitoring Kubernetes Sidecar
Example code that shows how a Kubernetes sidecar can monitor the file integrity of another container. The purpose of this project isn't to
provide production quality code; it's to show that it is possible to have a sidecar container monitor the file integrity of another container and to
take remedial action if a container is hacked.

## Container and Pod Security
There are many mechanisms to increase the security of applications deployed in containers such as:
 * namespaces to isolate containers
 * Linux capabilities to restrict what a container can do
 * seccomp profiles to provide fine-grained access to kernel calls
 * cgroups to limit the blast radius of a denial of service attack on a container

Despite all the container security options, it may still be prudent to run file integrity monitoring (FIM)/intrusion detection software such as
[AIDE]( https://aide.github.io/). However, an attacker who compromises a container might also be able to disable the FIM. This repository shows one way in which a
sidecar can monitor the file integrity of another container.

The containers in a pod share the same network namespace (so they share IP addresses and network connections) and the same UTS namespace (so they have the same 
hostname). By default, pods do not share the same process namespace. The pod's containers obviously have distinct file systems. However, if two containers share the 
same process namespace it is possible to allow them access to each other's file systems via the `procfs` virtual file system as noted in the 
[Kubernetes documentation](https://kubernetes.io/docs/tasks/configure-pod-container/share-process-namespace/). This example shows an artificially simple example of 
FIM using a sidecar container that shares a process namespace with an application container. The sidecar runs with greater privileges than the application 
container; the sidecar can access files in the application container but the application cannot read files in the sidecar container. 


## The Example Application
The code creates a Kubernetes pod that delivers a single HTML page with a "Hello, world!" message. The pod also contains a second (sidecar) container that 
checks whether the contents of the HTML page has been modified and, if so, kills the processes running in the first container and relies on the Kubernetes
controlplane to start a new instance of the container. The pod's service is exposed to the outside world by a LoadBalancer.

### Prerequisites
You'll need locally installed versions of
 * Docker
 * Minikube

### Building and running the application
To build and run the application, execute

```
$ ./build.sh
```

The build script starts up minikube, builds the container images for the application and sidecar, creates a pod with the two containers and creates a Kubernetes
load balancer service to make the application accessible. If the build script completes successfully, you should be able to see the pod as running and that
the pod contains two containers.

```
$ kubectl get pods
NAME           READY   STATUS    RESTARTS   AGE
hello-server   2/2     Running   0          10s
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
NAME           READY   STATUS    RESTARTS   AGE
hello-server   2/2     Running   0          5m26s
```

Next, in another terminal, modify the `index.html` page in the `hello-server` application container (which is in the `hello-server` pod)

```
$ kubectl exec -it hello-server -c hello-server -- bash
hellouser@hello-server:~$ echo hacked > index.html && exit
exit
```

The terminal showing the pod's state should show the pod go into error and then get restarted.

```
$ kubectl get pods -w
NAME           READY   STATUS    RESTARTS   AGE
hello-server   2/2     Running   0          5m26s
hello-server   1/2     Error     0          6m21s
hello-server   2/2     Running   1 (2s ago)   6m22s
```

Issuing an HTTP `GET` request should, once again, return the "Hello, world!" message since the container was restarted.

```
$ curl http://10.111.46.161
Hello, world!
```

## How does this work?
### Accessing files via `procfs`
To see how this works, open an `ash` shell to the `fim` container in the `hello-server` pod and list the processes.

```
$ kubectl exec -it hello-server -c fim -- ash
/ # ps aux
PID   USER     TIME  COMMAND
    1 65535     0:00 /pause
    7 1000      0:00 python -m http.server
   13 root      0:00 sleep infinity
  531 root      0:00 ash
  563 root      0:00 ps aux
```

The `ash` process, for example, is running within the `fim` container but the `http.server` process with PID 7 is running in the `hello-server` container.
Since the `fim` container is running with elevated privileges, we can access files on the `hello-server` container via symlinks in the `procfs` filesystem.
Using the fact that the PID of a process running in the `hello-server` container is 7, we can access the `index.html` file by running

```
/ # cat /proc/7/root/home/hellouser/index.html
Hello, world!
```

We can try a similar experiment in the `hello-server` container by opening a `bash` shell

```
$ kubectl exec -it hello-server -c hello-server -- bash
hellouser@hello-server:~$ ps aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
65535          1  0.0  0.0    972     4 ?        Ss   10:00   0:00 /pause
hellous+       7  0.0  0.1  19168 13512 ?        Ss   10:00   0:00 python -m http.server
root          13  0.0  0.0   1316     4 ?        Ss   10:00   0:00 sleep infinity
hellous+    3138  1.0  0.0   5756  3704 pts/0    Ss   10:20   0:00 bash
hellous+    3146  0.0  0.0   9396  3008 pts/0    R+   10:20   0:00 ps aux
```

Process 13 is running in the `fim` container but, this time, we cannot access the files since the `hello-server` container is not running with elevated
privileges

```
hellouser@hello-server:~$ ls /proc/13/root
ls: cannot access '/proc/13/root': Permission denied
```

### Checking file integrity as a liveness check
By default, Kubernetes polls containers for their liveness every 10 seconds. The `fim` container's liveness probe runs the [`healthz`](./containers/fim/healthz)
script. Thie script takes a file name and an MD5 hash value as arguments and checks that the file contents has the expected hash.
If the hashes don't match, the script (with a certain amount of hackery) determines all the processes running in the monitored container and issues a
`SIGKILL` to all the processes. Killing all the processes in that way crashes the container and Kubernetes restarts a new instance of the container.

Two observations:
* The `healthz` integrity test is minimal; we should be checking entire directories not just a single file. Running `AIDE` in the `fim` container would be better than performing a simple hash of only one file.
* While we invoke the integrity test as a liveness check, we could run our integrity testing in a loop in the `fim` container's main process.


## Getting this Code Production-ready
There are at least three improvements that should be made to run file integrity monitoring from a sidecar:
* Use proper intrusion detection software like AIDE or [Tripwire](https://tripwire.com) rather than hacking some MD5 integrity checking together
* Run the `fim` container with the minimum privileges needed
* Provide a dynamic admission controller to create the pod definitions for the monitored container. See the next subsection.

### Writing a FIM admission controller
The [`hello_server_pod`](./k8s_manifests/hello_server_pod.yaml) file includes a definition for the `fim` container including arguments that must be passed
to the pod's liveness check. End users should only need to specify their own container in the pod
definition and use metadata annotations to identify files and directories that should be monitored as part of intrusion detection. A FIM admission controller would
parse the pod's annotations and add an appropriate FIM container specification to the pod manifest.


## Looking at the Code in more depth
This is not production-grade code but, if you're bored, there are more implementation details in the README files in the [containers](./containers) and 
[k8s_manifests](./k8s_manifests) directories.

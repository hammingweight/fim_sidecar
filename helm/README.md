# Installing the FIM demo using Helm
If you'd prefer to install the FIM demo against a real Kubernetes cluster, you can use the Helm chart in this directory. For example,

```
$ helm install hello hello-server
```

or, if you want to install the demo in the `foobar` namespace

```
$ kubectl create namespace foobar
$ helm install -n foobar hello hello-server
```

The Helm install will tell you how to connect to the "Hello, world" service endpoint.

```
NAME: hello
LAST DEPLOYED: Sat Jun 18 20:20:28 2022
NAMESPACE: foobar
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
You can find the hello-service URL by running:
  export SERVICE_IP=$(kubectl get svc --namespace foobar hello-service --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
  echo http://$SERVICE_IP:80
```

Following the instructions will generate output like

```
$ export SERVICE_IP=$(kubectl get svc --namespace foobar hello-service --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
$ echo http://$SERVICE_IP:80
http://10.100.132.67:80
```

Then,

```
$ curl http://10.100.132.67:80
Hello, world!
```

You can use `kubectl` commands to interact with the containers in the pod

```
$ kubectl exec -it -n foobar hello-server -c hello-server -- bash
hellouser@hello-server:~$ ls -l
total 4
-rw------- 1 hellouser hellouser 14 Jun  5 09:53 index.html
hellouser@hello-server:~$ exit
exit
$ kubectl exec -it -n foobar hello-server -c fim -- ash
/ # ps aux
PID   USER     TIME  COMMAND
    1 65535     0:00 /pause
    8 1000      0:00 python -m http.server
   15 root      0:00 sleep infinity
 1240 root      0:00 ash
 1246 root      0:00 ps aux
/ # exit

```

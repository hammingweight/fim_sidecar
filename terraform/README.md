# Installing the FIM demo using Terraform
If you'd prefer to install the FIM demo against a real Kubernetes cluster, you can use the Terraform configuration in this directory. For example,

```
$ terraform apply
```

or, if you don't want to use your default Kubernetes context

```
$ terraform apply --var kube_config_context=minikube
```

or, if you want to install the demo in the `foobar` namespace

```
$ kubectl create namespace foobar
$ terraform apply --var namespace=foobar
```

The terraform output will provide the "Hello, world" service endpoint.

```
Apply complete! Resources: 2 added, 0 changed, 2 destroyed.

Outputs:

service_endpoint = "http://10.98.229.89:80"
```

Then,

```
$ curl http://10.98.229.89:80
Hello, world!
```

You can use `kubectl` commands to interact with the containers in the pod

```
$ kubectl exec -it -n foobar hello-server -c hello-server -- bash
hellouser@hello-server:~$ ls -l
total 4
-rw------- 1 hellouser hellouser 14 Jun  5  2022 index.html
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

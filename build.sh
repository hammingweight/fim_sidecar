#!/usr/bin/env bash
set -e
script_dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )"

HELLO_IMAGE_NAME=hammingweight/hello_server:1.0.2
docker build -t $HELLO_IMAGE_NAME $script_dir/containers/hello_server

FIM_IMAGE_NAME=hammingweight/fim:1.0.1
docker build -t $FIM_IMAGE_NAME $script_dir/containers/fim

if [ -z ${USE_MICROK8S} ]
then
    minikube start
    minikube image load $HELLO_IMAGE_NAME
    minikube image load $FIM_IMAGE_NAME
else
    docker save -o hello-server.tar $HELLO_IMAGE_NAME
    docker save -o fim.tar $FIM_IMAGE_NAME

    microk8s start
    mkdir -p $HOME/.kube
    cp $HOME/.kube/config $HOME/.kube/config.bak || true
    microk8s config > $HOME/.kube/config
    chmod 600 $HOME/.kube/config
    # We'll need a load balancer.
    microk8s enable metallb:10.64.140.43-10.64.140.49
    microk8s images import hello-server.tar
    microk8s images import fim.tar

    rm hello-server.tar
    rm fim.tar
fi

docker rmi $HELLO_IMAGE_NAME
docker rmi $FIM_IMAGE_NAME

kubectl apply -f $script_dir/k8s_manifests/

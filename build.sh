#!/usr/bin/env bash
set -e
script_dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )"

minikube start -n=3

HELLO_IMAGE_NAME=hammingweight/hello_server:1.0.0
docker build -t $HELLO_IMAGE_NAME $script_dir/containers/hello_server
minikube image load $HELLO_IMAGE_NAME

FIM_IMAGE_NAME=hammingweight/fim:1.0.0
docker build -t $FIM_IMAGE_NAME $script_dir/containers/fim
minikube image load $FIM_IMAGE_NAME

kubectl apply -f $script_dir/k8s_manifests/hello_server_deployment.yaml
kubectl apply -f $script_dir/k8s_manifests/hello_load_balancer_service.yaml

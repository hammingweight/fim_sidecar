#!/usr/bin/env bash
set -e
script_dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )"

minikube delete
minikube start

eval $(minikube docker-env)
docker build -t hello_server:1.0 $script_dir/containers/hello_server
docker build -t fim:1.0 $script_dir/containers/fim

kubectl apply -f $script_dir/k8s_resources/hello_server_pod.yaml
kubectl apply -f $script_dir/k8s_resources/hello_load_balancer_service.yaml

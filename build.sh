#!/usr/bin/env bash
set -e
script_dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )"

minikube start

eval $(minikube -p minikube docker-env)
docker build -t hammingweight/hello_server:1.0.0 $script_dir/containers/hello_server
docker build -t hammingweight/fim:1.0.0 $script_dir/containers/fim

kubectl apply -f $script_dir/k8s_manifests/hello_server_pod.yaml
kubectl apply -f $script_dir/k8s_manifests/hello_load_balancer_service.yaml

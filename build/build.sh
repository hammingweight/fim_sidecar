#!/bin/bash
set -e
script_dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )"

minikube delete
minikube start

eval $(minikube docker-env)
docker build -t httpserver:1.0 $script_dir/../containers/server
docker build -t fim:1.0 $script_dir/../containers/fim

kubectl apply -f $script_dir/../k8s_resources/serverpod.yaml
kubectl apply -f $script_dir/../k8s_resources/service.yaml

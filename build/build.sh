#!/bin/bash
set -e
minikube delete
minikube start

eval $(minikube docker-env)
docker build -t httpserver:1.0 ../containers/server
docker build -t fim:1.0 ../containers/fim

kubectl apply -f ../k8s_resources/serverpod.yaml
kubectl apply -f ../k8s_resources/service.yaml

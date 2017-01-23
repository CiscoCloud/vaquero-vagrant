#!/bin/bash
# masterIP
echo "Configuring kubectl"
kubectl config set-cluster default-cluster --server=http://$1:8080
kubectl config set-context default-context --cluster=default-cluster --user=default-admin
kubectl config use-context default-context

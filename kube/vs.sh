#!/bin/bash

kubectl create secret generic ssh-key --from-file=/vagrant/provision_files/secret/server.pem --from-file=/vagrant/provision_files/secret/server.key
kubectl create configmap vs-config --from-file=/vagrant/kube/vs-config.yaml
kubectl create -f /vagrant/kube/vsRc.yaml
kubectl create -f /vagrant/kube/vsSvc.yaml

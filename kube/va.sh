#!/bin/bash

kubectl create configmap va-config --from-file=/vagrant/kube/va-config.yaml
kubectl create -f /vagrant/kube/vaPod.yaml

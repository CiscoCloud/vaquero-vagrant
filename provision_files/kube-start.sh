#!/bin/bash

if [ $(hostname) = "vs-1" ]; then
  echo "Detected master, starting master services"
  ETCDCTL_API=2 etcdctl mkdir /kube-centos/network
  ETCDCTL_API=2 etcdctl mk /kube-centos/network/config "{ \"Network\": \"172.30.0.0/16\", \"SubnetLen\": 24, \"Backend\": { \"Type\": \"vxlan\" } }"

  for SERVICES in kube-apiserver kube-controller-manager kube-scheduler flanneld; do
    systemctl restart $SERVICES
    systemctl enable $SERVICES
  done
fi

echo "Starting minion services"
for SERVICES in kube-proxy kubelet flanneld docker; do
    systemctl restart $SERVICES
    systemctl enable $SERVICES
done

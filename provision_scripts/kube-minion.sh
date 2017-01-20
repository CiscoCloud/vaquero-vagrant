#!/bin/bash

#my IP, master IP:Port, ETCD CLUSTER STRING
KUBE_CONF=/etc/kubernetes/config
API_CONF=/etc/kubernetes/apiserver
FLA_CONF=/etc/sysconfig/flanneld
LET_CONF=/etc/kubernets/kubelet

sed -i "s#KUBELET_ADDRESS=\"--address=127.0.0.1\"#KUBELET_ADDRESS=\"--address=$1\"#" $LET_CONF
sed -i "s#KUBELET_API_SERVER=\"--api-servers=http://127.0.0.1:8080\"#KUBELET_API_SERVER=\"--api-servers=http://$2\"#" $LET_CONF
sed -i "s/# KUBELET_PORT/KUBELET_PORT/" $LET_CONF

sed -i "s#FLANNEL_ETCD_ENDPOINTS=\"http://127.0.0.1:2379\"#FLANNEL_ETCD_ENDPOINTS=\"$3\"#" $FLA_CONF
sed -i "s#/atomic.io/network#kube-centos/network#" $FLA_CONF

for SERVICES in kube-proxy kubelet flanneld docker; do
    systemctl restart $SERVICES
    systemctl enable $SERVICES
    systemctl status $SERVICES
done

kubectl config set-cluster default-cluster --server=http://$2
kubectl config set-context default-context --cluster=default-cluster --user=default-admin
kubectl config use-context default-context

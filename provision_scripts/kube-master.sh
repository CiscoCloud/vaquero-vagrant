#!/bin/bash

#my IP, ETCD CLUSTER STRING
KUBE_CONF=/etc/kubernetes/config
API_CONF=/etc/kubernetes/apiserver
FLA_CONF=/etc/sysconfig/flanneld

sed -i "s#127.0.0.1#$1#" $KUBE_CONF
echo "KUBE_ETCD_SERVERS=\"--etcd-servers=$2\"" >> $KUBE_CONF

sed -i "s/# KUBE_API_PORT/KUBE_API_PORT/" $API_CONF
sed -i "s/# KUBELET_PORT/KUBELET_PORT/" $API_CONF
sed -i "s#KUBE_ETCD_SERVERS=\"--etcd-servers=http://127.0.0.1:2379\"#KUBE_ETCD_SERVERS=\"--etcd-servers=$2\"#" $API_CONF

sed -i "s#FLANNEL_ETCD_ENDPOINTS=\"http://127.0.0.1:2379\"#FLANNEL_ETCD_ENDPOINTS=\"$2\"#" $FLA_CONF
sed -i "s#/atomic.io/network#kube-centos/network#" $FLA_CONF

setenforce 0
systemctl disable firewalld
systemctl stop firewalld
systemctl start etcd
etcdctl mkdir /kube-centos/network
etcdctl mk /kube-centos/network/config "{ \"Network\": \"172.30.0.0/16\", \"SubnetLen\": 24, \"Backend\": { \"Type\": \"vxlan\" } }"

for SERVICES in etcd kube-apiserver kube-controller-manager kube-scheduler flanneld; do
	systemctl restart $SERVICES
	systemctl enable $SERVICES
done

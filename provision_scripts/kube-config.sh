#!/bin/bash
#my IP, ETCD CLUSTER STRING
KUBE_CONF=/etc/kubernetes/config
API_CONF=/etc/kubernetes/apiserver
FLA_CONF=/etc/sysconfig/flanneld
LET_CONF=/etc/kubernetes/kubelet

if [ $1 = $2 ]; then
	echo "Loading Kube-Master"

	sed -i "s#KUBE_MASTER=\"--master=http://127.0.0.1:8080\"#KUBE_MASTER=\"--master=http://$2:8080\"#" $KUBE_CONF
	echo "KUBE_ETCD_SERVERS=\"--etcd-servers=$3\"" >> $KUBE_CONF

  sed -i "s/KUBE_API_ADDRESS=\"--insecure-bind-address=127.0.0.1\"/KUBE_API_ADDRESS=\"--insecure-bind-address=$2\"/" $API_CONF
	sed -i "s/# KUBE_API_PORT/KUBE_API_PORT/" $API_CONF
	sed -i "s/# KUBELET_PORT/KUBELET_PORT/" $API_CONF
	sed -i "s#KUBE_ETCD_SERVERS=\"--etcd-servers=http://127.0.0.1:2379\"#KUBE_ETCD_SERVERS=\"--etcd-servers=$3\"#" $API_CONF
  sed -i "s/KUBE_ADMISSION_CONTROL/#KUBE_ADMISSION_CONTROL/" $API_CONF

	sed -i "s#FLANNEL_ETCD_ENDPOINTS=\"http://127.0.0.1:2379\"#FLANNEL_ETCD_ENDPOINTS=\"$3\"#" $FLA_CONF
	sed -i "s#/atomic.io/network#kube-centos/network#" $FLA_CONF

	setenforce 0
	systemctl disable firewalld
	systemctl stop firewalld

	echo "Done configuring Kube-Master"
fi

echo "Loading Kube-Minion"

sed -i "s#KUBE_MASTER=\"--master=http://127.0.0.1:8080\"#KUBE_MASTER=\"--master=http://$2:8080\"#" $KUBE_CONF

sed -i "s#KUBELET_ADDRESS=\"--address=127.0.0.1\"#KUBELET_ADDRESS=\"--address=$1\"#" $LET_CONF
sed -i "s#KUBELET_API_SERVER=\"--api-servers=http://127.0.0.1:8080\"#KUBELET_API_SERVER=\"--api-servers=http://$2:8080\"#" $LET_CONF
sed -i "s#KUBELET_HOSTNAME=\"--hostname-override=127.0.0.1\"#KUBELET_HOSTNAME=\"--hostname-override=$1\"#" $LET_CONF
sed -i "s/# KUBELET_PORT/KUBELET_PORT/" $LET_CONF
sed -i "s#KUBELET_ARGS=\"\"#KUBELET_ARGS=\"--cluster-dns='10.0.2.3'\"#"

sed -i "s#FLANNEL_ETCD_ENDPOINTS=\"http://127.0.0.1:2379\"#FLANNEL_ETCD_ENDPOINTS=\"$3\"#" $FLA_CONF
sed -i "s#/atomic.io/network#kube-centos/network#" $FLA_CONF

echo "Done configuring Kube-Minion"

kubectl config set-cluster default-cluster --server=http://$2:8080
kubectl config set-context default-context --cluster=default-cluster --user=default-admin
kubectl config use-context default-context

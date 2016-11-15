#!/bin/bash

#Name, Current IP, cluster-string
ETCD_CONF=/home/vagrant/.etcd.conf
BASH_PROFILE=/home/vagrant/.bash_profile

echo "ETCD_NAME=$1" >> $ETCD_CONF
echo "ETCD_DATA_DIR=/var/lib/etcd" >> $ETCD_CONF
echo "ETCD_LISTEN_CLIENT_URLS=http://0.0.0.0:2379" >> $ETCD_CONF
echo "ETCD_ADVERTISE_CLIENT_URLS=http://$2:2379" >> $ETCD_CONF
echo "ETCD_LISTEN_PEER_URLS=http://0.0.0.0:2380" >> $ETCD_CONF
echo "ETCD_INITIAL_ADVERTISE_PEER_URLS=http://$2:2380" >> $ETCD_CONF
echo "ETCD_INITIAL_CLUSTER_STATE=new" >> $ETCD_CONF
echo "ETCDCTL_API=3" >> $ETCD_CONF
echo "ETCD_INITIAL_CLUSTER=$3" >> $ETCD_CONF

sudo cp /vagrant/provision_files/etcd.service /etc/systemd/system/etcd.service
sudo systemctl daemon-reload

echo "" >> $BASH_PROFILE
echo "set -o allexport" >> $BASH_PROFILE
echo "source $ETCD_CONF" >> $BASH_PROFILE

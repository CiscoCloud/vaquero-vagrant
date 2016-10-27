#!/bin/bash
BASH_PROFILE=/home/vagrant/.bash_profile

echo "Installing etcd..."
sudo yum -y install etcd
echo "Etcd installed. Configuring..."

echo "export ETCD_NAME=default" >> $BASH_PROFILE
echo "export ETCD_DATA_DIR=/var/lib/etcd/default.etcd" >> $BASH_PROFILE
echo "export ETCD_LISTEN_CLIENT_URLS=http://0.0.0.0:2379" >> $BASH_PROFILE
echo "export ETCD_ADVERTISE_CLIENT_URLS=http://localhost:2379" >> $BASH_PROFILE

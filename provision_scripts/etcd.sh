#!/bin/bash
echo "Installing etcd..."
sudo yum -y install etcd
echo "Etcd installed. Configuring..."
ETCD_NAME=default
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:2379"
ETCD_ADVERTISE_CLIENT_URLS="http://localhost:2379"

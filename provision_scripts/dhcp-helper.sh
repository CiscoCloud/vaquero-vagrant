#!/bin/bash
apt-get install dhcp-helper
sed -i 's/-b eth0/-s 10.10.11.5/' /etc/default/dhcp-helper
service dhcp-helper restart

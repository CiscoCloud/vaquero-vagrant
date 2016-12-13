docker run -p 24601:24601 -p 24600:24600 -d -v /vagrant/provision_files/ha_proxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro -v /dev/log:/dev/log -v /run/haproxy:/run/haproxy haproxy:1.5

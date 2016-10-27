curl http://downloads.drone.io/release/linux/amd64/drone.tar.gz | tar zx
sudo install -t /usr/local/sbin drone

BASH_PROFILE=/home/vagrant/.bash_profile

echo "export DRONE_SERVER=" >> $BASH_PROFILE
echo "export DRONE_TOKEN=" >> $BASH_PROFILE

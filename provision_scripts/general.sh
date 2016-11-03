# !/bin/bash
yum install -y git vim screen

BASH_PROFILE=/home/vagrant/.bash_profile

cd /
wget https://storage.googleapis.com/golang/go1.6.3.linux-amd64.tar.gz
tar xzvf go1.6.3.linux-amd64.tar.gz
rm go1.6.3.linux-amd64.tar.gz

echo "export PATH=$PATH:/go/bin" >> $BASH_PROFILE
echo "export GOROOT=/go" >> $BASH_PROFILE
echo "export GOPATH=/vagrant/go" >> $BASH_PROFILE


#govendor dependency for vaquero
go get -u github.com/kardianos/govendor

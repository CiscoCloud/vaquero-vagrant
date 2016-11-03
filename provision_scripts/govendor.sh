source /home/vagrant/.bash_profile

go get -u github.com/kardianos/govendor

go build github.com/kardianos/govendor

sudo mv govendor /go/bin

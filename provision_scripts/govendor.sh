source .bash_profile

#govendor dependency for vaquero
go get -u github.com/kardianos/govendor

go build github.com/kardianos/govendor

cp $GOPATH/src/github.com/kardianos/govendor/govendor /go/bin

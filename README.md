# Getting Started

1. `vagrant up`

2. `vagrant ssh vaquero`

3. `docker pull shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest`

4. `docker run -v /vagrant/config/git-server.yaml:/vaquero/config.yaml -v /var/vaquero/files:/var/vaquero/files --network="host" shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest standalone --config /vaquero/config.yaml`

## More details

## Source of Truth source options:
  - git: `vagrant/config/git-*.yaml`
  - local directory: `vagrant/config/vagrant-local.yaml`

## DHCP Deployment examples
  1. Vaquero utilizing its own DHCP server in "server" mode with no other DHCP in play.
    1. `vagrant up vaquero_server`
    2. `vagrant ssh vaquero_server`
    3. `docker pull shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest`
    4. `docker run -v /vagrant/config/git-server.yaml:/vaquero/config.yaml -v /var/vaquero/files:/var/vaquero/files --network="host" shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest standalone --config /vaquero/config.yaml`
  2. Vaquero **not** running its own DHCP or TFTP. Depending on DNSMASQ to provide that functionality. [dnsmasq.conf](https://github.com/CiscoCloud/vaquero/blob/master/vagrant/provision_files/dnsmasq-netboot.conf) used on `vaquero_dnsmasq` to provide DHCP & TFTP.
    1. `vagrant up vaquero_dnsmasq`
    2. `vagrant ssh vaquero_dnsmasq`
    3. `docker pull shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest`
    4. `docker run -v /vagrant/config/git-dnsmasq.yaml:/vaquero/config.yaml -v /var/vaquero/files:/var/vaquero/files --network="host" shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest standalone --config /vaquero/config.yaml`
  3. Vaquero running its own DHCP in proxy mode, the subnet has an existing DHCP server handing out IP addresses. [dnsmasq.conf](https://github.com/CiscoCloud/vaquero/blob/master/vagrant/provision_files/dnsmasq-iponly.conf) used by the `dnsmasq` box to provide only IPs.
    1. `vagrant up vaquero_proxy dnsmasq`
    2. `vagrant ssh vaquero_proxy`
    3. `docker pull shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest`
    4. `docker run -v /vagrant/config/git-proxy.yaml:/vaquero/config.yaml -v /var/vaquero/files:/var/vaquero/files --network="host" shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest standalone --config /vaquero/config.yaml`

## Using a directory as an SoT
 `docker run -v /vagrant/config/vagrant-local.yaml:/vaquero/config.yaml -v /var/vaquero/files:/var/vaquero/files -v /vagrant/local:/vagrant/local --network="host" shippedrepos-docker-vaquero.bintray.io/vaquero/vaquero:latest standalone --config /vaquero/config.yaml`

vagrant-local.yaml: Update from the data model at `./vagrant/local`
vagrant-git.yaml: Update from the data model at `https://github.com/gem-test/vaquero/tree/vagrant` (requires forwarding via ngrok for webhook updates, read below)


## Sending a webhook to the vaquero machine

1. Install [ngrok](https://ngrok.com/) to your local machine, unzip the package, and move the executable to `/usr/local/bin`.
2. Run ngrok on your physical machine `ngrok http 127.0.0.1:4816` or `ngrok http 4816`.
    1. Make sure that the address and port are the same as the Git Hook server in the config.
    2. It should follow `ngrok http <Gitter.Addr>:<Gitter.Port>`
3. Create a testing repo to launch webhooks from.
4. Give github.com the http endpoint provided by ngrok `http://0000ffff.ngrok.io/postreceive/vaquero-local`.
    1. This should be something like `<ngrok address>/<Gitter.Endpoint>/<GitHook.ID>`.
    2. The `Gitter.Endpoint` and the `GitHook.ID` are from the config.
5. Launch a webhook to hit the ngrok address.
    1. The `GitHook.Username`,`GitHook.Password`, and `GitHook.Secret` should be set in configuration to connect to the webhook of the `GitHook.URL`.
    2. Note that the `GitHook.Secret` can be left blank and should correspond to the Secret created when setting up the webhook on GitHub.
    3. Pushing to the repo, or `Redeliver Payload` on GitHub will launch a webhook.

## Building an example etcd-cluster
- Assumes 'Getting Started' is complete

1. Run `./cluster.sh -c 2` in `vagrant/create_cluster`
2. Open the node machines in virtualbox, wait for them to PXE boot (~5 minutes)
3. Check etcd `etcdctl cluster-health`

This environment will start up one etcd-proxy and etcd-master.

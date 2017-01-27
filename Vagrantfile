$cent = "geerlingguy/centos7"
$base = "gemini/base"
$vaquero = "gemini/vaquero"
$ubuntu = "ubuntu/trusty64"

$vs_num = (ENV['VS_NUM'] || 1).to_i
$va_num = (ENV['VA_NUM'] || 0).to_i
$dev = (ENV['V_DEV'] || 0).to_i
$relay = (ENV['V_RELAY'] || 0).to_i
$lb = (ENV['V_LB'] || 0).to_i
$max = 3

def medium(config, name)
    config.vm.provider "virtualbox" do |v|
        v.memory = 512
        v.cpus = 1
        v.name = name
    end
end

def large(config, name)
    config.vm.provider "virtualbox" do |v|
        v.memory = 2048
        v.cpus = 2
        v.name = name
    end
end

def setSize(config,name)
    if $relay != 0
      name = "relay-" + name
    end

    if $dev == 0
        medium(config, name)
    else
        large(config, name)
    end
end

def nat(config)
    config.vm.provider "virtualbox" do |v|
        v.customize ["modifyvm", :id, "--nic2", "natnetwork", "--nat-network2", "vaquero", "--nictype2", "82543GC"]
    end
end

def setNetwork(box, ipString)
    if $relay == 0
        box.vm.network "private_network", ip: ipString, virtualbox__intnet: "vaquero"
    else
        box.vm.network "private_network", ip: ipString, virtualbox__intnet: "relay"
        box.vm.provision :shell, inline: "sudo ip route add 10.10.10.0/24 via 10.10.11.3 dev enp0s8"
    end
end

def getIP(index,ipStart)
  if $relay == 0
    ipString = "10.10.10.#{index+ipStart}"
  else
    ipString = "10.10.11.#{index+ipStart}"
  end
end

def importDevPath(config)
  config.vm.provision "file", source: "~/.gitconfig", destination: "/home/vagrant/.gitconfig"
  if $dev != 0 && ENV['GOPATH'] != ""
    config.vm.synced_folder ENV['GOPATH'], "/home/vagrant/go"
  end
end

Vagrant.configure(2) do |config|
    if $va_num > $max
        abort("VA_NUM=#{$va_num}. It cannot be greater than #{$max}")
    end

    if $vs_num > $max
        abort("VS_NUM=#{$vs_num}. It cannot be greater than #{$max}")
    end

    peerCluster=""
    pubCluster=""
    masterIP=""
    $vs_num.times do |i|
        name = "vs-#{i+1}"
        ipStart = 5
        ipString = getIP(i, ipStart)
        peerCluster << sprintf("%s=http://%s:2380",name,ipString)
        pubCluster << sprintf("http://%s:2379",ipString)
        if i < $vs_num - 1
          peerCluster << ","
          pubCluster << ","
        end

        if i == 0
          masterIP = ipString
        end

        config.vm.define name do |server|
            server.vm.box = $vaquero
            setSize(config, name)
            setNetwork(server, ipString)
            importDevPath(server)
            server.vm.hostname = name
            server.vm.provision :shell, path: "provision_scripts/net-start.sh"
            server.vm.provision :shell, path: "provision_scripts/etcd-config.sh", args: "#{name} #{ipString} #{peerCluster}", privileged: false
            server.vm.provision :shell, path: "provision_scripts/etcd-start.sh"
            server.vm.provision :shell, path: "provision_scripts/govendor.sh"
            server.vm.provision :shell, path: "provision_scripts/docker-start.sh"
            server.vm.provision :shell, path: "provision_scripts/kube-config.sh", args: "#{ipString} #{masterIP} #{pubCluster}"
            server.vm.provision :shell, path: "provision_scripts/kubectl.sh", args: "#{masterIP}", privileged: false
            server.vm.provision "file", source: "provision_files/kube-start.sh", destination: "/home/vagrant/kube-start.sh"
        end
    end

    $va_num.times do |i|
        name = "va-#{i+1}"
        ipStart = 8
        ipString = getIP(i, ipStart)
        config.vm.define name do |agent|
            agent.vm.box = $vaquero
            setSize(config, name)
            setNetwork(agent, ipString)
            importDevPath(agent)
            agent.vm.hostname = name
            agent.vm.provision :shell, path: "provision_scripts/govendor.sh"
            agent.vm.provision :shell, path: "provision_scripts/docker-start.sh"
            agent.vm.provision :shell, path: "provision_scripts/net-start.sh"
        end
    end

    $relay.times do |i|
      i = 0
        config.vm.define "gateway" do |relay|
          medium(config, "gateway")
          relay.vm.hostname = "gateway"
          relay.vm.box = $ubuntu
          relay.vm.network "private_network", ip: "10.10.10.3", virtualbox__intnet: "vaquero"
          relay.vm.network "private_network", ip: "10.10.11.3", virtualbox__intnet: "relay"
          relay.vm.provision :shell, inline: "sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf && sysctl -p /etc/sysctl.conf"
          relay.vm.provision :shell, path: "provision_scripts/dhcp-helper.sh"
        end
    end

    $lb.times do |i|
      i = 0
      config.vm.define "lb" do |lb|
          medium(config, "lb")
          setNetwork(lb, "10.10.10.4")
          lb.vm.hostname = "lb"
          lb.vm.box = $vaquero
          lb.vm.network "forwarded_port", guest: 24600, host: 24600
          lb.vm.provision :shell, inline: 'echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf'
          lb.vm.provision :shell, path: "provision_scripts/docker-start.sh"
          lb.vm.provision :shell, path: "provision_scripts/net-start.sh"
          lb.vm.provision :shell, path: "provision_scripts/haproxy.sh"
      end
    end

    config.vm.define "dnsmasq", autostart: false do |dnsmasq|
        medium(config, "dnsmasq")
        dnsmasq.vm.network "private_network", ip: "10.10.10.4", virtualbox__intnet: "vaquero"
        dnsmasq.vm.box = $vaquero
        dnsmasq.vm.provision "file", source: "provision_files/dnsmasq-iponly.conf", destination: "/tmp/dnsmasq.conf"
        dnsmasq.vm.provision :shell, path: "provision_scripts/dnsmasq-start.sh"
        dnsmasq.vm.provision :shell, path: "provision_scripts/net-start.sh"
    end

    config.vm.define "build_vaquero", autostart: false do |vaquero|
        large(config, "build_vaquero")
        vaquero.vm.box = $base
        vaquero.ssh.insert_key = false
        vaquero.vm.provision :shell, path: "provision_scripts/general.sh"
        vaquero.vm.provision :shell, path: "provision_scripts/kube.sh"
        vaquero.vm.provision :shell, path: "provision_scripts/dnsmasq.sh"
        vaquero.vm.provision :shell, path: "provision_scripts/docker-start.sh"
        vaquero.vm.provision :shell, path: "provision_scripts/dnsmasq-start.sh"
        vaquero.vm.provision :shell, path: "provision_scripts/images.sh"
        vaquero.vm.provision :shell, path: "provision_scripts/etcd.sh"
        vaquero.vm.provision :shell, path: "provision_scripts/drone.sh"
    end

    # To build,
    # 1. `vagrant up base`
    # 2. `vagrant ssh base` (once it reboots)
    # 3. `sudo ./vb_guest.sh`
    config.vm.define "base", autostart: false do |base|
        large(config, "base")
        base.vm.box = $cent
        base.vm.box_version = "1.1.3"
        base.ssh.insert_key = false
        base.vm.provision :shell, inline: "yum -y update"
        base.vm.provision :shell, inline: "yum -y install dkms binutils gcc make patch libgomp glibc-headers glibc-devel kernel-headers kernel-devel"
        base.vm.provision "file", source: "provision_files/vb_guest.sh", destination: "/home/vagrant/vb_guest.sh"
        base.vm.provision :shell, inline: "reboot"
        base.vm.provision :shell, path: "provision_files/vb_guest.sh"
    end
end

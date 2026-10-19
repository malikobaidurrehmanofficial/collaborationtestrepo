Vagrant.configure("2") do |config|

  # Vagrant box
  config.vm.box = "eurolinux-vagrant/centos-stream-9"

  # VirtualBox configuration
  config.vm.provider "virtualbox" do |vb|
    vb.memory = 1024
    vb.cpus = 1
  end

  # Port forwarding: Host 8080 -> VM 80
  config.vm.network "forwarded_port",
    guest: 80,
    host: 8080

  # Shell provisioning
  config.vm.provision "shell",
    path: "provision.sh"

end
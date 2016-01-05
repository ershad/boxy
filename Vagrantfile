Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"

  config.vm.network "forwarded_port", guest: 80, host: 8080

  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.cpus = 2
  end

  # Remove default Chef & Puppet. build_box bootstraps
  # latest Chef
  config.vm.provision "shell", inline: <<-SCRIPT
    sudo apt-get purge chef chef-zero puppet -y
    sudo apt-get autoremove -y
  SCRIPT
end

# -*- mode: ruby -*-
# vi: set ft=ruby :


# https://trinca.tornidor.com/blog/from-wsl-to-virtualbox-vm
# https://devblogs.microsoft.com/commandline/chmod-chown-wsl-improvements/
# https://learn.microsoft.com/en-us/windows/wsl/wsl-config
# Create this files and paste content below into it.
# Note: Without this files, WSL2 will not connect to VirtualBox host.
# C:/Users/%UserProfile%/.wslconfig
# [wsl2]
# networkingMode=mirrored
# dnsTunneling=true
#
# Create this file in WSL, without it you cannot use linux permissions in DrvFs
# /etc/wsl.conf
# [automount]
# enabled = true
# options = "metadata,uid=1000,gid=1000,umask=0022,fmask=11,case=off"
# mountFsTab = false
# crossDistro = true

# Then reload wsl with current config: wsl --shutdown && wsl

# Then add this to the end of ~/.bashrc file:
# export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
# export VAGRANT_HOME="/home/andrey/.vagrant.d/"
# export VAGRANT_WSL_WINDOWS_ACCESS_USER_HOME_PATH="/mnt/c/Users/Andrey"
# export PATH="$PATH:/mnt/c/WINDOWS/system32"
# export PATH="$PATH:/mnt/c/WINDOWS/System32/WindowsPowerShell/v1.0"
# export PATH="$PATH:/mnt/c/Program Files/Oracle/VirtualBox"
# export PATH="$PATH:/mnt/c/Program\ Files/Oracle/VirtualBox"

# TEMP DrvFs mount: 'sudo mount -t drvfs C: /mnt/c -o metadata,uid=1000,gid=1000' until you wsl have been restarted.

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "generic/centos8"

  # Create a forwarded port mapping which allows access to a specific
  # port within the machine from a port on the host machine. 
  # use this command in powershell to list bridges: 
  # Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Select-Object Name, InterfaceDescription
  # Note: you must enable networkingMode=mirrored in WSL2 to use the 
  # same loopback interface that VrtualBox apply to host below:
  config.ssh.host = "127.0.0.1"
  config.ssh.port = 2222
  config.vm.network "public_network", bridge: "Беспроводная сеть", guest: 22, host: 2222, host_ip: "127.0.0.1"

  #config.vm.network "private_network", type: "dhcp", netmask: "255.255.255.0", auto_config: true, nic_type: "82540EM", virtualbox__intnet: "NatNetwork"
  config.vm.provider "virtualbox" do |vb|   
    host_port = VagrantExtraVars::Store.pass_vars['http_port_forward'].to_s
    unless host_port.empty?
      rule      = "http,tcp,127.0.0.1,#{host_port},,80" 
      # puts "NAT forwarding rule: #{rule}"
      vb.customize ["modifyvm", :id, "--natpf1", rule]
    end
  end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "playbook.yaml"
    args = VagrantExtraVars::Store.pass_vars.select { |k, _| k.start_with?("ansible_") }
                  .map do |k, v|
                    short_key = k.sub(/^ansible_/, "")
                    "#{short_key}=#{v}"
                  end
                  .join(" ")
    puts "[DEBUG] Ansible will be executed with: --extra-vars #{args}" unless args.empty?
    ansible.raw_arguments = ["--extra-vars", args] unless args.empty?
  end

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Disable the default share of the current code directory. Doing this
  # provides improved isolation between the vagrant box and your host
  # by making sure your Vagrantfile isn't accessible to the vagrant box.
  # If you use this you may want to enable additional shared subfolders as
  # shown above.
  # config.vm.synced_folder ".", "/vagrant", disabled: true

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Run Testinfra if --pass_vars contains run_pytest = true and pytest_path = [path]/tests.py
  if VagrantExtraVars::Store.pass_vars['run_pytest'].to_s.downcase == 'true'
    config.trigger.after :up do |trigger|
      test_path = VagrantExtraVars::Store.pass_vars['pytest_path'] || '.'
      trigger.run = { inline: "bash -c 'set -ex; tests/configure_pytest.sh && vagrant ssh-config > .vagrant/ssh-config && py.test --hosts=default --ssh-config=.vagrant/ssh-config #{test_path}/tests.py'" }
      trigger.name = "Run pytest"
    end
  end
end

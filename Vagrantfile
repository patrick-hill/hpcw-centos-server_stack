# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrant's Ansible Docs: http://docs.vagrantup.com/v2/provisioning/ansible.html
# Vagrant Automatic Inventory File: .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory
# Vagrant 1.7 auto Private Key Location: .vagrant/machines/[machine name]/[provider]/private_key

# Example Layout: https://github.com/debops/examples/blob/master/vagrant-multi-machine/Vagrantfile

# Config
RAM     = '1024'  # Default memory size in MB
DOMAIN  = ".hpcw.com"
NETWORK = "192.168.125."
NETMASK = "255.255.255.0"
BOX     = 'centos71-nocm-0.0.1.box'

HOSTS = [
  {
    :name   => 'proxy',
    :cpu    => '1',
    :mem    => RAM,
    :eth1   => NETWORK+'5',
    :box    => BOX,
    :ports  => [
      {:g => 443, :h => 8443 },
      {:g => 80, :h => 8080 }
    ] 
  },
  {
    :name   => 'stack',
    :cpu    => '1',
    :mem    => RAM,
    :eth1   => NETWORK+'6',
    :box    => BOX,
    :ports  => [
      {:g => 8080, :h => 8080}, # sabnzbd
      {:g => 8081, :h => 8081}, # sickrage
      {:g => 5050, :h => 5050}, # couchpotato
      {:g => 8181, :h => 8181}, # headphones
      {:g => 8989, :h => 8998}  # Sonarr
    ]
   }
]

Vagrant.require_version ">= 1.7.0"

VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  
  # Hostmanager Configs
  config.hostmanager.enabled = true             # Enable HostMan Plugin
  config.hostmanager.manage_host = true         # Update Host's host file
  config.hostmanager.ignore_private_ip = false  
  config.hostmanager.include_offline = true
  
  HOSTS.each do |opts|
    config.vm.define opts[:name] do |config|
      config.vm.box       = opts[:box]    
      config.vm.hostname  = opts[:name] + DOMAIN
      config.vm.network :private_network, ip: opts[:eth1], netmask: NETMASK
      config.vm.provider :virtualbox do |v|
        v.customize ["modifyvm", :id, "--memory", opts[:mem]]
        v.customize ["modifyvm", :id, "--cpus", opts[:cpu]]
      end
      opts[:ports].each do |port|
        config.vm.network :forwarded_port, guest:port[:g] , host: port[:h], auto_correct: true
      end
    end
    
    # Provisioning
    config.vm.provision "shell", path: "scripts/#{opts[:name]}/#{opts[:name]}.sh", args: opts[:eth1]
    # config.vm.provision :ansible do |ansible|
    #   ansible.verbose = "v"                         # Tells vagrant to display ansible command used
    #   ansible.playbook = "ansible/#{name}.yml"
    # end
    
  end # HOSTS-each
end
# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

BOX_URL = "https://oracle.github.io/vagrant-projects/boxes"
BOX_NAME = "oraclelinux/8"

ui = Vagrant::UI::Prefixed.new(Vagrant::UI::Colored.new, "vagrant")

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  VM_NAME = default_s('VM_NAME', 'DBserver')
  VM_MEMORY = default_i('VM_MEMORY', 2560)
  VM_SYSTEM_TIMEZONE = default_s('VM_SYSTEM_TIMEZONE', host_tz)
  VM_ORACLE_BASE = default_s('VM_ORACLE_BASE', '/opt/oracle')
  VM_ORACLE_HOME = default_s('VM_ORACLE_HOME', '/opt/oracle/product/21c/dbhome_1')
  VM_ORACLE_SID = default_s('VM_ORACLE_SID', 'ORCLCDB')
  VM_ORACLE_PDB = default_s('VM_ORACLE_PDB', 'ORCLPDB1')
  VM_ORACLE_CHARACTERSET = default_s('VM_ORACLE_CHARACTERSET', 'AL32UTF8')
  VM_ORACLE_EDITION = default_s('VM_ORACLE_EDITION', 'EE')
  VM_NGINX_GUEST_PORT = default_i('VM_NGINX_GUEST_PORT', 80)
  VM_NGINX_HOST_PORT = default_i('VM_NGINX_HOST_PORT', 1001)
  VM_LISTENER_PORT = default_i('VM_LISTENER_PORT', 1521)
  VM_EM_EXPRESS_PORT = default_i('VM_EM_EXPRESS_PORT', 5500)
  VM_ORACLE_PWD = default_s('VM_ORACLE_PWD', '')
end

def default_s(key, default)
  ENV[key] && ! ENV[key].empty? ? ENV[key] : default
end

def default_i(key, default)
  default_s(key, default).to_i
end

def host_tz
  offset_sec = Time.now.gmt_offset
  if (offset_sec % (60 * 60)) == 0
    offset_hr = ((offset_sec / 60) / 60)
    timezone_suffix = offset_hr >= 0 ? "-#{offset_hr.to_s}" : "+#{(-offset_hr).to_s}"
    'Etc/GMT' + timezone_suffix
  else
    'UTC'
  end
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = BOX_NAME
  config.vm.box_url = "#{BOX_URL}/#{BOX_NAME}.json"
  config.vm.define VM_NAME
  #virtualbox Windows/Linux
  config.vm.provider "virtualbox" do |v|
    v.memory = VM_MEMORY
    v.name = VM_NAME
  end
  #KVM Linux
  config.vm.provider :libvirt do |v|
    v.memory = VM_MEMORY
  end

  config.vm.hostname = VM_NAME
  config.vm.network "private_network", type: "dhcp"
 # config.vm.network "forwarded_port", guest: VM_NGINX_GUEST_PORT, host: VM_NGINX_HOST_PORT
  config.vm.network "forwarded_port", guest: VM_LISTENER_PORT, host: VM_LISTENER_PORT
  config.vm.network "forwarded_port", guest: VM_EM_EXPRESS_PORT, host: VM_EM_EXPRESS_PORT
  config.vm.provision "ansible", playbook: "play.yml"
end

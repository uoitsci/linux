# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "ubuntu/xenial64"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"
  
  config.vm.synced_folder ".", "/vagrant", owner: "science", group: "science"

  #config.ssh.username = "science"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
    vb.memory = "4096"
  end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Provisions the VM using a shell script.  Right now it updates
  # the installed packages, installs scripts to support packaging,
  # and creates the Science user to properly populate the changelog.
  config.vm.provision "shell", inline: <<-SHELL
    sed -i 's/archive.ubuntu.com/mirror.science.uoit.ca/g' /etc/apt/sources.list

    sudo locale-gen en_CA.UTF-8

    sudo apt-get update > /dev/null
    sudo apt-get dist-upgrade -y > /dev/null
    sudo apt-get install -y devscripts config-package-dev debhelper gnupg-agent pinentry-curses > /dev/null
    sudo apt-get autoremove -y > /dev/null

    # Create a user if it doesn't already exist.
    if [ $(id -u science &>/dev/null) ]
    then
      echo "User does not exist, creating."
      sudo useradd -m -c "Science Administrator" -s /bin/bash science

      cat <<EOF > /home/science/.bashrc
export DEBFULLNAME="Science Software"
export DEBEMAIL="software@science.uoit.ca"
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export GPGKEY=EF4C1D02

eval \$(gpg-agent --daemon)
EOF
      
      mkdir -p /home/science/.gnupg

      cat <<EOF > /home/science/.gnupg/gpg.conf
default-key 621CC013
keyserver hkp://keys.gnupg.net
keyserver-options auto-key-retrieve
use-agent
personal-digest-preferences SHA512
cert-digest-algo SHA512
default-preference-list SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed
EOF

      cat <<EOF > /home/science/.gnupg/gpg-agent.conf
pinentry-program /usr/bin/pinentry-curses
no-grab
default-cache-ttl 1800
EOF
      
      chown -R science:science /home/science/.gnupg
    else
      echo "User already exists, ignoring."
    fi
  SHELL
end

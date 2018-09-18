#!/bin/bash
set -x

# Turn off reverse DNS lookups so SSH login is faster
echo 'UseDNS no' >> /etc/ssh/sshd_config

# Turn off unused SSH authentication protocols
sed -i '/GSSAPIAuthentication / s/ .*/ no/' /etc/ssh/sshd_config

# Setup vagrant user and insecure SSH public key
useradd vagrant
mkdir -m 0700 -p /home/vagrant/.ssh
curl https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub >> /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh
echo "vagrant ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Allow ssh to send remote commands using sudo. 
# Without this change vagrant will be unable to
# apply changes (such as configuring additional NICs)
# at startup.
sed -i 's/^\(Defaults.*requiretty\)/#\1/' /etc/sudoers

# Remove device specific configuration
rm -f /etc/udev/rules.d/70-persistent-net.rules
touch /etc/udev/rules.d/70-persistent-net.rules

# Install a fresh eth0 configuration file
cat > /etc/sysconfig/network-scripts/ifcfg-eth0 <<EOL
DEVICE=eth0
NAME=eth0
BOOTPROTO=dhcp
NM_CONTROLLED=no
PERSISTENT_DHCLIENT=1
ONBOOT=yes
TYPE=Ethernet
DEFROUTE=yes
PEERDNS=yes
PEERROUTES=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
IPV6_AUTOCONF=no
IPV6_DEFROUTE=yes
IPV6_PEERDNS=yes
IPV6_PEERROUTES=yes
IPV6_FAILURE_FATAL=no
EOL

# Disable root password and login
#passwd -d root
#passwd -l root

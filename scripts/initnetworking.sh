#!/bin/bash
set -x

# Turn off reverse DNS lookups so SSH login is faster
echo 'UseDNS no' >> /etc/ssh/sshd_config

# Turn off unused SSH authentication protocols
sed -i '/GSSAPIAuthentication / s/ .*/ no/' /etc/ssh/sshd_config

# Install cloud-init packages
yum -y install cloud-utils cloud-init cloud-utils-growpart parted git

cat > /etc/cloud/cloud.cfg.d/02_user.cfg <<EOL
system_info:
  default_user:
    name: centos
    lock_passwd: true
    gecos: CentOS user
    groups: [wheel, adm, systemd-journal]
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    shell: /bin/bash
EOL

# Disable zeroconf
echo 'NOZEROCONF=yes' >> /etc/sysconfig/network
echo 'PERSISTENT_DHCLIENT=yes' >> /etc/sysconfig/network

# Make sure output shows up in nova console-log and OpenStack VNC/SPICE consoles
sed -i '/GRUB_CMDLINE_LINUX=/ s/=.*/=\"console=tty0 crashkernel=auto console=ttyS0,115200\"/' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg

# Remove device specific configuration
rm -f /etc/udev/rules.d/70-persistent-net.rules
touch /etc/udev/rules.d/70-persistent-net.rules

# eth0 is usually the device with the default gateway.
# Make sure the eth1 default gateway doesn't clobber the eth0 default gateway.
echo 'GATEWAYDEV=eth0' >> /etc/sysconfig/network

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

# Support second network interface
cat > /etc/sysconfig/network-scripts/ifcfg-eth1 <<EOL
DEVICE=eth1
NAME=eth1
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
passwd -d root
passwd -l root

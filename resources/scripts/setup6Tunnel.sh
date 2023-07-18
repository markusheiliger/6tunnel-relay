#!/bin/bash

# install required packages
sudo apt-get install 6tunnel net-tools

# patch DHCP client configuration
cat << EOF | sudo tee -a /etc/dhcp/dhclient.conf

# Enable IPv6 
# https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-ipv6-for-linux?tabs=ubuntu
timeout 10;

EOF

# patch network configuration
cat << EOF | sudo tee /etc/cloud/cloud.config.d/91-azure-network.cfg

network:
  version: 2
  ethernets:
  eth0:
    dhcp4: true
    dhcp6: true
    match:
      driver: hv_netvsc
    set-name: eth0

EOF
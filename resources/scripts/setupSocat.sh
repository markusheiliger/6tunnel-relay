#!/bin/bash

# install required packages
sudo apt install -y socat 

# patch DHCP client configuration
cat << EOF | sudo tee -a /etc/dhcp/dhclient.conf

# Enable IPv6 
# https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-ipv6-for-linux?tabs=ubuntu
timeout 10;

EOF

# patch network configuration
cat << EOF | sudo tee /etc/cloud/cloud.cfg.d/91-azure-network.cfg

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

# create socat systemd unit
# cat << EOF | sudo tee /etc/systemd/system/socat.target

# [Unit]
# Description=Create socat port forwarding
# After=network-online.target
# Wants=network-online.target

# [Service]
# Type=simple
# ExecStart=/usr/bin/socat UDP4-LISTEN:500,fork,su=nobody UDP6:[2a00:6020:488e:1700::53]:500
# ExecStart=/usr/bin/socat UDP4-LISTEN:4500,fork,su=nobody UDP6:[2a00:6020:488e:1700::53]:4500
# Restart=on-failure

# [Install]
# WantedBy=multi-user.target

# EOF
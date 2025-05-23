#!/bin/bash

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -a -G docker ubuntu

# MISC
sudo apt install unzip
sudo apt-get install iptables-persistent

## iptables
sudo iptables -I INPUT -p tcp --dport 5901 -m state --state NEW -j ACCEPT # for VNC
sudo iptables -I INPUT -p tcp --dport 54839 -m state --state NEW -j ACCEPT # for FRP
sudo iptables -I INPUT -p udp --dport 54839 -m state --state NEW -j ACCEPT # for FRP
sudo netfilter-persistent save
# test
# nc -zv SERVER_IP 5901


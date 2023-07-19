#!/bin/bash

echo '====================================================================================================================='
echo `$(basename "$0") $@`
echo '====================================================================================================================='

export DEBCONF_NOWARNINGS=yes
export DEBIAN_FRONTEND=noninteractive

# patch needrestart config
[ -f '/etc/needrestart/needrestart.conf' ] \
	&& sed -i 's/#$nrconf{restart}.*/$nrconf{restart} = '"'"'l'"'"';/g' /etc/needrestart/needrestart.conf

# register Microsoft package feed
curl -sSL https://packages.microsoft.com/config/$(lsb_release -si)/$(lsb_release -sr)/prod.list | sudo tee /etc/apt/sources.list.d/microsoft-prod.list
curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
sudo dpkg -i packages-microsoft-prod.deb && rm packages-microsoft-prod.deb

# update and upgrade packages
sudo apt update -y && sudo apt upgrade -y 

# install commonly used packages
sudo apt install -y apt-utils apt-transport-https coreutils


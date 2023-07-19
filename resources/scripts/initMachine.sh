#!/bin/bash

echo '====================================================================================================================='
echo `$(basename "$0") $@`
echo '====================================================================================================================='

export DEBCONF_NOWARNINGS=yes
export DEBIAN_FRONTEND=noninteractive

# patch needrestart config
[ -f '/etc/needrestart/needrestart.conf' ] \
	&& sed -i 's/#$nrconf{restart}.*/$nrconf{restart} = '"'"'l'"'"';/g' /etc/needrestart/needrestart.conf

# register Microsoft package feed (https://learn.microsoft.com/en-us/linux/packages)
curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo apt-add-repository https://packages.microsoft.com/$(lsb_release -si | tr '[:upper:]' '[:lower:]')/$(lsb_release -sr)/prod

# update and upgrade packages
sudo apt update -y && sudo apt upgrade -y 

# install commonly used packages
sudo apt install -y apt-utils apt-transport-https coreutils net-tools


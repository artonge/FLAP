#!/bin/bash

set -e

################################################################################
echo "UPDATING SYSTEM"
apt update
apt upgrade -y

# Install tools
apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

################################################################################
echo "INSTALLING DOCKER"
# Add docker repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
apt-key fingerprint 0EBFCD88

add-apt-repository "deb [arch=armhf] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Install docker
apt update
apt install -y docker-ce docker-ce-cli containerd.io

# Start docker on start
systemctl enable docker

# Check that everything is working properly
docker run hello-world

################################################################################
echo "INSTALLING DOCKER-COMPOSE"
apt install -y python3-pip libffi-dev
pip3 install setuptools wheel docker-compose

################################################################################
echo "CREATING ALIASES"
echo "alias dc='docker-compose'" >> /root/.bashrc
echo "alias dprune='docker container prune -f && docker volume prune -f && docker network prune -f && docker image prune -f'" >> /root/.bashrc
source /root/.bashrc

################################################################################
echo "EXPOSING LOCAL DOMAIN NAME FOR GUI SETUP (flap.local)"
hostname flap
apt install -y avahi-daemon

################################################################################
echo "INSTALLING FLAP"
# Install dependencies
apt install -y git gettext certbot upnpc unattended-upgrades

# Fetch git repository
git clone --recursive git@gitlab.com:flap-box/flap.git /flap

################################################################################
echo "ENABLING AUTO UPDATE"
echo "
Unattended-Upgrade::Allowed-Origins {
        "${distro_id}:${distro_codename}";
        "${distro_id}:${distro_codename}-security";
        "${distro_id}:${distro_codename}-updates";
};
Unattended-Upgrade::Mail 'louis@chmn.me';
Unattended-Upgrade::MinimalSteps 'true';
Unattended-Upgrade::Remove-Unused-Kernel-Packages 'true';
Unattended-Upgrade::Remove-Unused-Dependencies 'true';
Unattended-Upgrade::Automatic-Reboot 'true';
Unattended-Upgrade::Automatic-Reboot-Time '03:00';
" > /etc/apt/apt.conf.d/50unattended-upgrades

echo "
APT::Periodic::Update-Package-Lists '1';
APT::Periodic::Download-Upgradeable-Packages '1';
APT::Periodic::AutocleanInterval '7';
APT::Periodic::Unattended-Upgrade '1';
" > /etc/apt/apt.conf.d/20auto-upgrades

################################################################################
echo "SETTING UP FLAP"
cd /flap

echo "export FLAP_DIR=/flap" >> /root/.bashrc
echo "export FLAP_DATA=/var/lib/flap" >> /root/.bashrc
source /root/.bashrc
ln -s $FLAP_DIR/system/cli/manager.sh /bin/manager

# Execute configuration actions with the manager
# TLS certificates will be generated during setup
manager ports open 80
manager ports open 443
manager config generate
manager setup cron

# Start all services
dc up -d

# Run post setup scripts for each services
for service in $(ls $FLAP_DIR)
do
    if [ -f $FLAP_DIR/$service/scripts/post_setup.sh ]
    then
        $FLAP_DIR/$service/scripts/post_setup.sh
    fi
done

################################################################################
echo "DONE"

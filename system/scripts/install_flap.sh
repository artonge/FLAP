#!/bin/bash

set -e

# Prevent interactions during apt install
export DEBIAN_FRONTEND=noninteractive

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

add-apt-repository "deb https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Install docker
apt update
apt install -y docker-ce docker-ce-cli containerd.io

# Start docker on start
systemctl_path=$(which systemctl || true)
if [ "$systemctl_path" != "" ]
then
    systemctl enable docker
fi

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
# Prevent setting hostname in CI env.
if [ "$CI" != "" ]
then
    hostname flap
fi
apt install -y avahi-daemon

################################################################################
echo "INSTALLING FLAP"
# Install dependencies
apt install -y git gettext certbot miniupnpc unattended-upgrades

# Prevent key fingerprint cheking during git clone
mkdir -p ~/.ssh/
echo "|1|qWGcIFxLWr0h9SzQkmBcgT5IbAE=|d+v+RHzFM2if/RxyEoULgVbpfaI= ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFSMqzJeV9rUzU4kWitGjeR4PWSa29SPqJ1fVkhtj3Hw9xjLVXVYrU9QlYWrOLXBpQ6KWjbjTDTdDkoohFzgbEY=
|1|2SQ3Snv+OKzpk7W07KYHfOUO7oc=|Cy0/SFy7JqLx8l3fBZ8ZGCXANEg= ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFSMqzJeV9rUzU4kWitGjeR4PWSa29SPqJ1fVkhtj3Hw9xjLVXVYrU9QlYWrOLXBpQ6KWjbjTDTdDkoohFzgbEY=
" > ~/.ssh/known_hosts

# Fetch git repository
git clone --recursive https://gitlab.com/flap-box/flap.git /opt/flap

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
# Allow to override FLAP_DIR.
# Usefull in docker-in-docker env where we can't bind volumes from the current container but from the host.
echo "export FLAP_DIR="${FLAP_DIR:-/opt/flap}"" >> /etc/environment
echo "export FLAP_DATA=/flap/system" >> /etc/environment
source /etc/environment
ln -sf $FLAP_DIR/system/cli/manager.sh /bin/manager
mkdir -p /var/log/flap

# Execute configuration actions with the manager.
manager setup cron
# Prevent openning ports in CI env.
if [ "$CI" != "" ]
then
    manager ports open 80
    manager ports open 443
fi
manager config generate
manager tls generate flap.local local

# Create data directory for each services
for service in $(ls -d $FLAP_DIR/*/)
do
    mkdir -p /flap/$(basename $service)
done

cd $FLAP_DIR

# Start all services
docker-compose up -d

# Run post setup scripts for each services
manager hooks post_install

################################################################################
echo "DONE"

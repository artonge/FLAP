#!/bin/bash

set -eu

BRANCH=${1-master}
echo "INSTALLING BRANCH: $BRANCH"

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

################################################################################
echo "INSTALLING DOCKER-COMPOSE"
apt install -y python3-pip libffi-dev libssl-dev
pip3 install setuptools wheel docker-compose

################################################################################
echo "CREATING ALIASES"
echo "alias dc='docker-compose'" >> /root/.bashrc
echo "alias dprune='docker container prune -f && docker volume prune -f && docker network prune -f && docker image prune -f'" >> /root/.bashrc
set +u # Prevent undefined variables to crash bashrc execution
source /root/.bashrc
set -u

################################################################################
echo "ENABLING AUTO UPDATE"
apt install -y unattended-upgrades

echo '
Unattended-Upgrade::Allowed-Origins {
        "${distro_id}:${distro_codename}";
        "${distro_id}:${distro_codename}-security";
        "${distro_id}:${distro_codename}-updates";
};
Unattended-Upgrade::Mail "louis@chmn.me";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-Time "03:00";
' > /etc/apt/apt.conf.d/50unattended-upgrades

echo '
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
' > /etc/apt/apt.conf.d/20auto-upgrades

################################################################################
echo "SETTING UP ENV VARS"
echo "export FLAP_DIR=/opt/flap" > /etc/environment
echo "export FLAP_DATA=/flap" >> /etc/environment
source /etc/environment
ln -sf $FLAP_DIR/system/cli/manager.sh /bin/manager

################################################################################
echo "INSTALLING FLAP"
# Install dependencies
# git: fetch updates
# certbot: generate TLS certificates
# miniupnpc: open ports
# avahi-daemon: set the mDNS name
# mdam: Setup RAID
# jq: manipulate json text files
# psmisc: better cli output
apt install -y \
    git \
    gettext \
    certbot \
    miniupnpc \
    avahi-daemon \
    mdadm \
    jq \
    psmisc

# Prevent key fingerprint cheking during git clone
mkdir -p ~/.ssh/
echo "|1|qWGcIFxLWr0h9SzQkmBcgT5IbAE=|d+v+RHzFM2if/RxyEoULgVbpfaI= ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFSMqzJeV9rUzU4kWitGjeR4PWSa29SPqJ1fVkhtj3Hw9xjLVXVYrU9QlYWrOLXBpQ6KWjbjTDTdDkoohFzgbEY=
|1|2SQ3Snv+OKzpk7W07KYHfOUO7oc=|Cy0/SFy7JqLx8l3fBZ8ZGCXANEg= ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFSMqzJeV9rUzU4kWitGjeR4PWSa29SPqJ1fVkhtj3Hw9xjLVXVYrU9QlYWrOLXBpQ6KWjbjTDTdDkoohFzgbEY=
" > ~/.ssh/known_hosts

# Fetch git repository
git clone --recursive https://gitlab.com/flap-box/flap.git $FLAP_DIR

if [ "$BRANCH" != 'master' ]
then
    echo "CHECKING OUT $BRANCH"
    cd $FLAP_DIR
    git checkout $BRANCH
    git pull
    git submodule update --init
fi


################################################################################
echo "DONE"

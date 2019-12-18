#!/bin/bash

set -eu

BRANCH_OR_TAG=${1:-master}
echo "INSTALLING BRANCH_OR_TAG: $BRANCH_OR_TAG"

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
apt install -y \
    docker-ce=5:18.09.8~3-0~ubuntu-bionic \
    docker-ce-cli=5:18.09.8~3-0~ubuntu-bionic \
    containerd.io=1.2.6-3

# Start docker on start.
# Check if we are in a docker container with systemctl.
if [ "$(which systemctl || true)" != "" ]
then
    systemctl enable docker
fi

################################################################################
echo "INSTALLING DOCKER-COMPOSE"
apt install -y python3-pip libffi-dev libssl-dev
pip3 install setuptools wheel docker-compose

################################################################################
echo "CREATING ALIASES"
echo "alias dc='docker-compose'" > /root/.bash_aliases
echo "alias dprune='docker container prune -f && docker volume prune -f && docker network prune -f && docker image prune -f'" >> /root/.bash_aliases
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
ln -sf $FLAP_DIR/system/cli/flapctl.sh /bin/flapctl

################################################################################
echo "INSTALLING FLAP"
# Install dependencies
# git: fetch updates
# certbot: generate TLS certificates
# miniupnpc: open ports
# avahi-daemon: set the mDNS name
# mdam: setup RAID
# jq: manipulate json text files
# psmisc: better cli output with pstree
apt install -y \
    git \
    gettext \
    certbot \
    miniupnpc \
    avahi-daemon \
    mdadm \
    jq \
    psmisc

# yq: manipulate yaml text files.
pip3 install yq

# Removing useless packages.
apt remove -y postfix dovecot
apt purge -y postfix dovecot
apt autoremove

# Fetch git repository
git clone --recursive https://gitlab.com/flap-box/flap.git $FLAP_DIR

if [ "$BRANCH_OR_TAG" != 'master' ]
then
    echo "CHECKING OUT $BRANCH_OR_TAG"
    cd $FLAP_DIR
    git fetch --tags --prune
    git checkout $BRANCH_OR_TAG
    git submodule update --init
fi


################################################################################
echo "DONE"

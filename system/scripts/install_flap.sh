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
echo "INSTALLING FLAP"
# Install dependencies
apt install -y git envsubst certbot upnpc

# Fetch git repository
git clone --recursive git@gitlab.com:flap-box/flap.git /flap
################################################################################
echo "EXPOSING LOCAL DOMAIN NAME FOR GUI SETUP (flap.local)"
hostname flap
apt install -y avahi-daemon

################################################################################
echo "SETTING UP FLAP"
cd /flap

export "export FLAP_DIR=/flap" >> /root/.bashrc
export "export FLAP_DATA=/var/lib/flap" >> /root/.bashrc
echo "ln -s /flap/system/cli/manager.sh /bin/manager" >> /root/.bashrc
source /root/.bashrc

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

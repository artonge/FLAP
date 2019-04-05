#!/bin/bash

################################################################################
echo "UPDATING SYSTEM"
apt update
apt upgrade

################################################################################
echo "INSTALLING DOCKER"
# Install dependencies
apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

# Add docker repository
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
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
alias dc='docker-compose'
alias dprune='docker container prune -f && docker volume prune -f && docker network prune -f && docker image prune -f'

################################################################################
echo "INSTALLING FLAP"
# Install dependencies
apt install -y git

# Fetch git repository
git clone --recursive git@gitlab.com:flap-box/flap.git
################################################################################
echo "EXPOSING LOCAL DOMAIN NAME FOR GUI SETUP (flap.local)"
hostname flap
apt install avahi-daemon

################################################################################
echo "SETTING UP FLAP"
cd /flap

#
./system/setup.sh

################################################################################
echo "DONE"

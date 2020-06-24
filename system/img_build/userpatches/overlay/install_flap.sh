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
	gnupg2 \
	software-properties-common

################################################################################
echo "INSTALLING DOCKER"
# Add docker repository
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
apt-key fingerprint 0EBFCD88

add-apt-repository "deb https://download.docker.com/linux/debian $(lsb_release -cs) stable"

# Install docker
apt update
apt install -y \
	docker-ce=5:19.03.7~3-0~debian-buster \
	docker-ce-cli=5:19.03.7~3-0~debian-buster \
	containerd.io=1.2.6-3

# Start docker on boot.
# Check if we are in a docker container with systemctl.
if [ "$(command -v systemctl || true)" != "" ]
then
	systemctl enable docker
fi

################################################################################
echo "INSTALLING DOCKER-COMPOSE"
apt install -y \
	python3 python3-pip \
	python3-setuptools python3-wheel \
	python3-dev build-essential libffi-dev libssl-dev \
	libsodium23 libsodium-dev

# Use system's libsodium to avoid long compile time.
export SODIUM_INSTALL=system
pip3 install docker-compose

################################################################################
echo "ENABLING AUTO UPDATE"
apt install -y unattended-upgrades

# shellcheck disable=SC2016
echo '
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}";
    "${distro_id}:${distro_codename}-security";
    "${distro_id}:${distro_codename}-updates";
};
Unattended-Upgrade::Mail "root";
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
echo "FLAP_DIR=/opt/flap" > /etc/environment
echo "FLAP_DATA=/flap" >> /etc/environment
# shellcheck disable=SC1091
source /etc/environment
ln -sf "$FLAP_DIR/system/cli/flapctl.sh" /bin/flapctl

################################################################################
echo "INSTALLING FLAP DEPENDENCIES"
# Install dependencies
# avahi-daemon: set the mDNS name
# borgbackup: backups
# bsdmainutils: for the column cmd
# certbot: generate TLS certificates
# cron: periodic tasks
# gettext: envsubst
# git: fetch updates
# iproute2: use the ip cmd
# jq: manipulate json text files
# libssl-dev: to install docker-compose
# mdadm: setup RAID
# miniupnpc: open ports
# msmtp msmtp-mta: to send mail with sendmail
# psmisc: better cli output with pstree
# restic: backups
# ssh: to allow remote connection
# ufw: firewall
# wget: for clean http requests in flapctl
apt install -y \
	avahi-daemon \
	borgbackup \
	bsdmainutils \
	certbot \
	cron \
	gettext \
	git \
	iproute2 \
	jq \
	libssl-dev \
	mdadm \
	miniupnpc \
	msmtp msmtp-mta \
	psmisc \
	restic \
	ssh \
	ufw \
	wget

# yq: manipulate yaml text files.
pip3 install yq

# Removing useless packages.
apt remove -y postfix dovecot
apt purge -y postfix dovecot
apt autoremove -y

echo "ADDING LETSENCRYPT HOOKS"
# Setting certbot hooks.
mkdir -p /etc/letsencrypt/renewal-hooks/pre
mkdir -p /etc/letsencrypt/renewal-hooks/post
echo "flapctl stop" > /etc/letsencrypt/renewal-hooks/pre/stop_flap.sh
echo "flapctl start" > /etc/letsencrypt/renewal-hooks/post/start_flap.sh
chmod +x /etc/letsencrypt/renewal-hooks/pre/stop_flap.sh
chmod +x /etc/letsencrypt/renewal-hooks/post/start_flap.sh

echo "DISABLING PASSWORD AUTH FOR SSH"
# Customize sshd config.
sed -i 's/#\?PasswordAuthentication .*/PasswordAuthentication no/g' /etc/ssh/sshd_config

echo "FETCHING FLAP REPOSITORY"
# Fetch git repository
git clone --recursive https://gitlab.com/flap-box/flap.git "$FLAP_DIR"

if [ "$BRANCH_OR_TAG" != 'master' ]
then
	echo "CHECKING OUT $BRANCH_OR_TAG"
	cd "$FLAP_DIR"
	git fetch --tags --prune
	git checkout "$BRANCH_OR_TAG"
	git submodule update --init
fi

echo "INSTALLING FLAP'S SYSTEMD SERVICE"
cp "$FLAP_DIR/system/flap.service" /etc/systemd/system
if [ "$(command -v systemctl || true)" != "" ]
then
	systemctl enable flap
fi

################################################################################
echo "DONE"

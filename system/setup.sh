# INSTALL DOCKER
# Install dependencies
apt install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common

# Add docker repository
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
apt-key fingerprint 0EBFCD88

echo "deb [arch=armhf] https://download.docker.com/linux/debian \
     $(lsb_release -cs) stable" | \
     tee /etc/apt/sources.list.d/docker.list

# Install docker
apt update
apt install docker-ce

# Start docker on start
systemctl enable docker

# INSTALL DOCKER-COMPOSE
apt install python3-pip
pip3 install setuptools wheel docker-compose

# CREATE ALIASES
alias dc='docker-compose'
alias dprune='docker container prune -f && docker volume prune -f && docker network prune -f && docker image prune -f'

# INSTALL FLAP
# Install dependencies
apt install git

# Fetch git repository
git clone https://gitlab.com/artonge/flap.git

# Setup
dc up manager

# Start FLAP
dc up -d

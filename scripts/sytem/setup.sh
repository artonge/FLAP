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

# Create TLS certificates
createSSLCerts() {
	openssl req -x509 -out certificat.crt -keyout key.key \
			-newkey rsa:2048 -nodes -sha256 \
			-subj "/CN=$1" -extensions EXT \
			-config <(printf "[dn]\nCN=$1\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:$1\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")

	mv ./certificat.crt /etc/ssl/nginx/$1.crt
	mv ./key.key /etc/ssl/nginx/$1.key
}

createSSLCerts "flap.localhost"
createSSLCerts "files.flap.localhost"
createSSLCerts "home.flap.localhost"

# Start FLAP
dc up -d

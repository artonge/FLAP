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
createSSLCerts "sogo.flap.localhost"

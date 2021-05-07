# See https://ssl-config.mozilla.org/#server=nginx&version=1.17.7&config=intermediate&openssl=1.1.1d&guideline=5.6

# SSL certificates
ssl_certificate /etc/letsencrypt/live/flap/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/flap/privkey.pem;
# Verify chain of trust of OCSP response using Root CA and Intermediate certs
ssl_trusted_certificate /etc/letsencrypt/live/flap/chain.pem;

ssl_session_timeout 1d;
ssl_session_cache shared:MozSSL:10m;  # about 40000 sessions
ssl_session_tickets off;

# curl https://ssl-config.mozilla.org/ffdhe2048.txt > /path/to/dhparam
ssl_dhparam /etc/nginx/parts.d/dhparam;

# intermediate configuration
# Keep only TLS 1.2 (+ TLS 1.3)
ssl_protocols TLSv1.2 TLSv1.3;
# Use only strong ciphers
ssl_ciphers TLS-CHACHA20-POLY1305-SHA256:TLS-AES-256-GCM-SHA384:TLS-AES-128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
# Use more secure ECDH Curve
ssl_ecdh_curve X25519:P-521:P-384:P-256;
# Defend against the BEAST attack
ssl_prefer_server_ciphers off;

# OCSP Stapling
ssl_stapling on;
ssl_stapling_verify on;

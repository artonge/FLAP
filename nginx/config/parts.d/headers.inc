# Security headers
add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
# HTTP Strict Transport Security
add_header Strict-Transport-Security "max-age=63072000; includeSubdomains" always;
# Control the behavior of the Referrer header (Referrer-Policy)
add_header Referrer-Policy "no-referrer";
# Provide clickjacking protection (X-Frame-Options)
add_header X-Frame-Options "SAMEORIGIN" always;
# Prevent some categories of XSS attacks (X-XSS-Protection)
add_header X-XSS-Protection "1; mode=block" always;
# Prevent Sniff Mimetype middleware (X-Content-Type-Options)
add_header X-Content-Type-Options "nosniff" always;
# Reject unsafe HTTP methods
add_header Allow "GET, POST, HEAD" always;
# Limit resource access to the resource's domain.
add_header Access-Control-Allow-Origin "https://$host";

auth_request /lmauth_basic;
auth_request_set $lmremote_user $upstream_http_lm_remote_user;
auth_request_set $lmlocation $upstream_http_location;
auth_request_set $cookie_value $upstream_http_set_cookie;
auth_request_set $lmcookie $upstream_http_cookie;

# Set cookie for multi domain: https://lemon.flap.localhost/doc/pages/documentation/current/cda.html
add_header Set-Cookie $cookie_value;

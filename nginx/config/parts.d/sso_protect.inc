auth_request /lmauth;

set $original_uri $uri$is_args$args;

include parts.d/sso_populate_vars.inc;

# Redirect to portal for authentification when needed.
error_page 401 $lmlocation;

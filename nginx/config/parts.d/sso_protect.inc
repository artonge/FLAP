auth_request /lmauth;

include parts.d/sso_populate_vars.inc;

# Redirect to portal for authentification when needed.
error_page 401 $lmlocation;

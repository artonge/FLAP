auth_request /lmauth_basic;

set $original_uri $uri$is_args$args;

include parts.d/sso_populate_vars.inc;

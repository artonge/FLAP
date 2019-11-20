# Split the populate vars logic to prevent redirection on error 401 for apps that don't need it, like nextcloud.
include parts.d/sso_populate_vars.inc;

# Redirect to portal for authentification when needed.
error_page 401 $lmlocation;

#!/bin/bash

set -eu

echo "General configuration"
php /var/www/html/console --quiet config:set --section="General" --key="force_ssl" --value="1"
php /var/www/html/console --quiet config:set --section="General" --key="enable_update_communication" --value="0"
php /var/www/html/console --quiet config:set --section="General" --key="piwik_professional_support_ads_enabled" --value="0"

echo "Run cron job to keep system check happy"
php /var/www/html/console --quiet core:archive

echo "Update email settings"
php /var/www/html/console --quiet config:set --section="mail" --key="defaultHostnameIfEmpty" --value="analytics.$PRIMARY_DOMAIN_NAME"
php /var/www/html/console --quiet config:set --section="mail" --key="transport" --value="smtp"
php /var/www/html/console --quiet config:set --section="mail" --key="host" --value="$EMAIL_SMTP_HOST"
php /var/www/html/console --quiet config:set --section="mail" --key="port" --value="$EMAIL_SMTP_PORT"
php /var/www/html/console --quiet config:set --section="mail" --key="type" --value="Plain"
php /var/www/html/console --quiet config:set --section="mail" --key="username" --value="$EMAIL_SMTP_USER"
php /var/www/html/console --quiet config:set --section="mail" --key="password" --value="$EMAIL_SMTP_PASSWORD"
php /var/www/html/console --quiet config:set --section="mail" --key="encryption" --value="tls"
php /var/www/html/console --quiet config:set --section="General" --key="noreply_email_address" --value="admin@$PRIMARY_DOMAIN_NAME"

echo "Enable LDAP plugin"
php /var/www/html/console --quiet plugin:activate LoginLdap

echo "Update ldap settings"
php /var/www/html/console --quiet config:set --section="LoginLdap_flap" --key="hostname" --value="$LDAP_HOST"
php /var/www/html/console --quiet config:set --section="LoginLdap_flap" --key="port" --value="389"
php /var/www/html/console --quiet config:set --section="LoginLdap_flap" --key="base_dn" --value="$LDAP_BASE"
php /var/www/html/console --quiet config:set --section="LoginLdap_flap" --key="admin_user" --value="$LDAP_ADMIN_DN"
php /var/www/html/console --quiet config:set --section="LoginLdap_flap" --key="admin_pass" --value="$LDAP_ADMIN_PWD"

php /var/www/html/console --quiet config:set --section="LoginLdap" --key="servers[]" --value="flap"
php /var/www/html/console --quiet config:set --section="LoginLdap" --key="use_webserver_auth" --value="1"
php /var/www/html/console --quiet config:set --section="LoginLdap" --key="ldap_user_id_field" --value="uid"
php /var/www/html/console --quiet config:set --section="LoginLdap" --key="ldap_last_name_field" --value=""
php /var/www/html/console --quiet config:set --section="LoginLdap" --key="ldap_first_name_field" --value="cn"
php /var/www/html/console --quiet config:set --section="LoginLdap" --key="ldap_mail_field" --value="mail"
# php /var/www/html/console --quiet config:set --section="LoginLdap" --key="ldap_alias_field" --value="cn"
php /var/www/html/console --quiet config:set --section="LoginLdap" --key="use_ldap_for_authentication" --value="1"
php /var/www/html/console --quiet config:set --section="LoginLdap" --key="new_user_default_sites_view_access" --value="all"

echo "Perform db migration"
php /var/www/html/console --quiet core:update --yes

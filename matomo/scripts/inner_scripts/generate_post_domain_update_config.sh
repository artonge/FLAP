#!/bin/bash

set -eu

# Reset trusted_hosts[] since the config:set always creates a new entry.
sed '/trusted_hosts\[\] = "/d' -i /var/www/html/config/config.ini.php
for domain in $DOMAIN_NAMES
do
	php /var/www/html/console --quiet config:set --section="General" --key="trusted_hosts" --value="analytics.$domain"
done

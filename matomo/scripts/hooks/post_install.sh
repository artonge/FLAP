#!/bin/bash

set -eu

echo "Download extra plugins."
rm --recursive --force "$FLAP_DATA"/matomo/html/plugins/LoginLdap
git clone --depth 1 --branch 4.0.8 https://github.com/matomo-org/plugin-LoginLdap.git "$FLAP_DATA"/matomo/html/plugins/LoginLdap


# Check certificates with local CA for local domains.
provider=$(cat "$FLAP_DATA/system/data/domains/$PRIMARY_DOMAIN_NAME/provider.txt")
if [ "$provider" == "local" ]
then
	ca_cert=(--cacert /etc/letsencrypt/live/flap/root.cer)
fi

echo "Configure database"
curl "https://analytics.$PRIMARY_DOMAIN_NAME/index.php?action=databaseSetup&clientProtocol=https" \
	--location \
	--output /dev/null \
	--data "type=InnoDB&host=mariadb&username=matomo&password=$MATOMO_DB_PWD&dbname=matomo&tables_prefix=&adapter=PDO%5CMYSQL&submit=Next+%C2%BB" \
	"${ca_cert[@]}"

echo "Create admin"
curl "https://analytics.$PRIMARY_DOMAIN_NAME/index.php?action=setupSuperUser&clientProtocol=https&module=Installation" \
	--location \
	--output /dev/null \
	--data "login=admin&password=$ADMIN_PWD&password_bis=$ADMIN_PWD&email=$ADMIN_EMAIL%40server.local&submit=Next+%C2%BB" \
	"${ca_cert[@]}"

echo "Create example website"
curl "https://analytics.$PRIMARY_DOMAIN_NAME/index.php?action=firstWebsiteSetup&clientProtocol=https&module=Installation" \
	--location \
	--output /dev/null \
	--data "siteName=Example&url=https%3A%2F%2F$PRIMARY_DOMAIN_NAME&timezone=UTC&ecommerce=0&submit=Next+%C2%BB" \
	"${ca_cert[@]}"

echo "Finish installation"
curl "https://analytics.$PRIMARY_DOMAIN_NAME/index.php?action=finished&clientProtocol=https&module=Installation&site_idSite=1&site_name=Example" \
	--location \
	--output /dev/null \
	--data 'do_not_track=1&anonymise_ip=1&submit=Continue+to+Matomo+%C2%BB' \
	"${ca_cert[@]}"


# Geolocation provider. with 'geoip2php', matomo looks for specific hardcoded databases uses misc/
# shellcheck disable=SC2016
docker-compose exec -T mariadb mysql \
 	--password="$ADMIN_PWD" \
	--database "matomo" \
	--execute 'INSERT INTO `option` (option_name, option_value) VALUES ("usercountry.location_provider", "geoip2php");'

# We run archiving via a cron job. disable browser triggered archiving.
# https://matomo.org/docs/setup-auto-archiving/#disable-browser-triggers-for-matomo-archiving-and-limit-matomo-reports-to-updating-every-hour
# shellcheck disable=SC2016
docker-compose exec -T mariadb mysql \
 	--password="$ADMIN_PWD" \
	--database "matomo" \
	--execute 'INSERT INTO `option` (option_name, option_value) VALUES ("enableBrowserTriggerArchiving", 0);'


echo "Finish matomo install."
docker-compose exec -T --user www-data matomo /inner_scripts/generate_initial_config.sh

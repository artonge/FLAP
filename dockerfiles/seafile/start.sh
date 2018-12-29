#!/bin/bash

set -e

# Wait for MariaDB to be up before starting
while ! mysqladmin ping -hmariadb -useafile -pseafile --silent
do
	echo "Waiting for MariaDB..."
    sleep 2
done

# Setup seafile if it is not already setup
if [ ! -f /root/installed ]
then
	echo "Seting up DB and file system"
	./seafile-server-${SEAFILE_VERSION}/setup-seafile-mysql.sh auto --use-existing-db 1
	# Specifying admin credentials for seafile to setup it up
	echo "{\"email\": \"$SEAFILE_ADMIN_EMAIL\", \"password\":\"$SEAFILE_ADMIN_PASSWORD\"}" > conf/admin.txt

	mv /root/conf /root/conf.base
	# Fix SERVICE_URL value
	sed -i -e 's/SERVICE_URL = http:\/\/'$SERVER_IP':8000/SERVICE_URL = https:\/\/'$SERVER_IP'/g' /root/conf.base/ccnet.conf

	# Mark the instance as installed so we don't go throught the DB setup again
	touch /root/installed
fi

# Clean old conf folder
rm -rf /root/conf
mkdir /root/conf

# Merge base and addon conf files
cp /root/conf.base/* /root/conf/
cat /root/conf.addons/ccnet.conf >> /root/conf/ccnet.conf
cat /root/conf.addons/seafile.conf >> /root/conf/seafile.conf
cat /root/conf.addons/seafdav.conf >> /root/conf/seafdav.conf
cat /root/conf.addons/seahub_settings.py >> /root/conf/seahub_settings.py

# Start seahub and seafile
./seafile-server-${SEAFILE_VERSION}/seafile.sh start
./seafile-server-${SEAFILE_VERSION}/seahub.sh start 8001

exit_script() {
	# clear the trap
    trap - SIGINT SIGTERM
	# Stop seafile and seahub
	./seafile-server-${SEAFILE_VERSION}/seafile.sh stop
	./seafile-server-${SEAFILE_VERSION}/seahub.sh stop
}

# Call exit_script on SIGINT or SIGTERM
# This will cleanly shut down seafile and seahub on `docker-compose stop`
trap exit_script SIGINT SIGTERM

# Never return from the script because we need a "deamon" in docker
sleep infinity

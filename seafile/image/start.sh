#!/bin/bash

set -e

# Wait for MariaDB to be up before starting
while ! mysqladmin ping -hmariadb -useafile -pseafile --silent
do
	echo "Waiting for MariaDB..."
    sleep 2
done

# Setup seafile if it is not already setup
if [ ! -f /shared/installed ]
then
	# Move the downloaded server in the persistant volume.
	# It is necessary to copy this folder as seafile will alter it during setup.
	cp -r /root/seafile-server-6.3.4 /shared/

	echo "Seting up DB and file system"
	/shared/seafile-server-${SEAFILE_VERSION}/setup-seafile-mysql.sh auto --use-existing-db 1

	# Specifying admin credentials for seafile to setup it up
	echo "{\"email\": \"$SEAFILE_ADMIN_EMAIL\", \"password\":\"$SEAFILE_ADMIN_PASSWORD\"}" > /shared/conf/admin.txt

	# Save generated conf
	mv /shared/conf /shared/conf.base

	# Mark the instance as installed so we don't go throught the DB setup again
	touch /shared/installed
fi

# Clean old conf folder
rm -rf /shared/conf
mkdir /shared/conf

# Merge generated and specified conf
cp /shared/conf.base/* /shared/conf/
cat /conf/ccnet.conf >> /shared/conf/ccnet.conf
cat /conf/seafile.conf >> /shared/conf/seafile.conf
cat /conf/seafdav.conf >> /shared/conf/seafdav.conf
cat /conf/seafevents.conf >> /shared/conf/seafevents.conf
cat /conf/seahub_settings.py >> /shared/conf/seahub_settings.py

# Start seahub and seafile
/shared/seafile-server-${SEAFILE_VERSION}/seafile.sh start
/shared/seafile-server-${SEAFILE_VERSION}/seahub.sh start

exit_script() {
	# clear the trap
  trap - SIGINT SIGTERM
	# Stop seafile and seahub
	/shared/seafile-server-${SEAFILE_VERSION}/seafile.sh stop
	/shared/seafile-server-${SEAFILE_VERSION}/seahub.sh stop
}

# Call exit_script on SIGINT or SIGTERM
# This will cleanly shut down seafile and seahub on `docker-compose stop`
trap exit_script SIGINT SIGTERM

# Never return from the script because we need a "deamon" in docker
sleep infinity

#!/bin/bash

set -e

# Wait for MariaDB to be up before starting
while ! mysqladmin ping -hmariadb -useafile -pseafile --silent
do
	echo "Waiting for MariaDB..."
    sleep 2
done

if [ ! -f /home/seafile/installed ]
then
	echo "Seting up DB and file system"
	./seafile-server-${SEAFILE_VERSION}/setup-seafile-mysql.sh auto --use-existing-db 1
	# Specifying admin credentials for seafile to setup it up
	echo "{\"email\": \"$SEAFILE_ADMIN_EMAIL\", \"password\":\"$SEAFILE_ADMIN_PASSWORD\"}" > conf/admin.txt

	# Mark the instance as installed so we don't go throught it again
	touch /home/seafile/installed
fi

# Start seahub and seafile
./seafile-server-${SEAFILE_VERSION}/seafile.sh start
./seafile-server-${SEAFILE_VERSION}/seahub.sh start

exit_script() {
	# clear the trap
    trap - SIGINT SIGTERM
	# Stop seafile and seahub
	./seafile-server-${SEAFILE_VERSION}/seafile.sh stop
	./seafile-server-${SEAFILE_VERSION}/seahub.sh stop
}

# Call exit_script on SIGINT or SIGTERM
trap exit_script SIGINT SIGTERM

# Never return from the script because we need a "deamon" for docker
sleep infinity

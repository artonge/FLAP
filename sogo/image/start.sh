#!/bin/bash

set -e

# Wait for MariaDB to be up before starting
while ! mysqladmin ping -hmariadb -useafile -pseafile --silent
do
	echo "Waiting for MariaDB..."
    sleep 2
done

/usr/local/sbin/sogod \
	-WONoDetach YES \
	-WOLogFile - \
	-WOPort 0.0.0.0:20000

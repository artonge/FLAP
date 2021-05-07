#!/bin/bash

set -eu

# Version v1.14.7

echo "* [24] Update certbot hooks."
if [ -f /etc/letsencrypt/renewal-hooks/pre/stop_flap.sh ]
then
	echo "flapctl stop nginx" > /etc/letsencrypt/renewal-hooks/pre/stop_flap.sh
fi

if [ -f /etc/letsencrypt/renewal-hooks/post/start_flap.sh ]
then
	echo "flapctl start nginx" > /etc/letsencrypt/renewal-hooks/post/start_flap.sh
fi

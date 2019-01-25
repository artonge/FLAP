#!/bin/bash

# When not limiting the open file descritors limit, the memory consumption of
# slapd is absurdly high. See https://github.com/docker/docker/issues/8231
ulimit -n 8192

set -e

if [[ ! -d /etc/ldap/slapd.d ]]; then
	echo "Config initialisation..."

	mv /etc/ldap.bak/* /etc/ldap

	# Exit if we don't have PASSWORD or DOMAIN
	if [[ -z "$SLAPD_PASSWORD" ]]; then
		echo -n >&2 "Error: Container not configured and SLAPD_PASSWORD not set. "
		echo >&2 "Did you forget to add -e SLAPD_PASSWORD=... ?"
		exit 1
	fi

	if [[ -z "$SLAPchangetype: modify
D_DOMAIN" ]]; then
		echo -n >&2 "Error: Container not configured and SLAPD_DOMAIN not set. "
		echo >&2 "Did you forget to add -e SLAPD_DOMAIN=... ?"
		exit 1
	fi

	SLAPD_ORGANIZATION="${SLAPD_ORGANIZATION:-${SLAPD_DOMAIN}}"

	cat <<-EOF | debconf-set-selections
		slapd slapd/no_configuration boolean false
		slapd slapd/password1 password $SLAPD_PASSWORD
		slapd slapd/password2 password $SLAPD_PASSWORD
		slapd shared/organization string $SLAPD_ORGANIZATION
		slapd slapd/domain string $SLAPD_DOMAIN
		slapd slapd/backend select HDB
		slapd slapd/allow_ldap_v2 boolean false
		slapd slapd/purge_database boolean false
		slapd slapd/move_old_database boolean true
EOF

	# Gives ownership to the openldap user
	# chown -R openldap:openldap /etc/ldap/ /var/lib/ldap/ /var/run/slapd/

	# Finish slapd installation since it was avorted during image build
	echo "Reconfiguring slapd..."
	dpkg-reconfigure -f noninteractive slapd >/dev/null 2>&1

	# Split the DOMAIN. example.com ==> dc=example,dc=com
	dc_string=""
	IFS="."; declare -a dc_parts=($SLAPD_DOMAIN); unset IFS
	for dc_part in "${dc_parts[@]}"; do
		dc_string="$dc_string,dc=$dc_part"
	done
	# Replace the BASE in ldap.conf
	sed -i "s/^#BASE.*/BASE ${dc_string:1}/g" /etc/ldap/ldap.conf

	# Set admin password
	if [[ -n "$SLAPD_CONFIG_PASSWORD" ]]; then
		# Get password hash
		password_hash=`slappasswd -s "${SLAPD_CONFIG_PASSWORD}"`
		sed_safe_password_hash=${password_hash//\//\\\/}

		slapcat -n0 -F /etc/ldap/slapd.d -l /tmp/config.ldif
		sed -i "s/\(olcRootDN: cn=admin,cn=config\)/\1\nolcRootPW: ${sed_safe_password_hash}/g" /tmp/config.ldif
		rm -rf /etc/ldap/slapd.d/*
		slapadd -n0 -F /etc/ldap/slapd.d -l /tmp/config.ldif
		rm /tmp/config.ldif
	fi
fi

if [[ ! -f "/populated" && -d "/prepopulate" ]]; then
	# Load prepopulation .ldif files
	echo "Loading populate files..."
	for file in `ls /prepopulate/*.ldif`; do
		slapadd -F /etc/ldap/slapd.d -l "$file"
	done

	touch /populated
fi

echo "Starting slapd..."
# Start ldap as user and group 'openldap'
# -d is debug level, 0 means none, but without -d, slapd runs in background mode
exec slapd -d 0 -u openldap -g openldap

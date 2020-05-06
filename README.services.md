# FLAP services

---

FLAP services are a collection of scripts and configuration files. This file is a reference of those to help improving a service integration with FLAP.

-   [Templates](#templates)
-   [Special files](#special-files)
    -   [nginxconf](#nginxconf)
    -   [configlemon.jq](#configlemon.jq)
    -   [docker-composeyml](#docker-composeyml)
-   [Hooks](#hooks)
    -   [load_env](#load_env)
    -   [should_install](#should_install)
    -   [generate_config](#generate_config)
    -   [init_db](#init_db)
    -   [pre_install](#pre_install)
    -   [wait_ready](#wait_ready)
    -   [post_install](#post_install)
    -   [post_domain_update](#post_domain_update)
    -   [post_update](#post_update)
-   [Migrations](#migrations)
-   [Custom docker image](#custom-docker-image)
-   [Cron jobs](#cron_jobs)

## Templates

FLAP uses templates to generate configuration files.

To create a templates, simply create a file that respect the following syntax:
`<name>.template.<extension>`.

For example: `sogo.template.conf` will be rendered to `sogo.conf`.
Another example: most services are using `<service>.env` file that are used in there `docker-compose.yml`.

You can place the template file anywhere.

The templates will be rendered before any docker-compose call.

Templates are rendered with [`envsubst`](https://www.gnu.org/software/gettext/manual/html_node/envsubst-Invocation.html).

Advantages:

-   Having up to date configuration files on each starts. This also allows fast experimentation.
-   Using the service's configuration file syntax so we do not have to invent a new one.
-   Clear visualization of the current service's configurations.

Limits:

-   Does not support complex configuration tweaks. For example, matrix needs the `pre_install` hooks to further customize the configuration.

## Special files

FLAP uses some special files for services integration.

#### `nginx.conf`

If the service needs exposure to thought Nginx you can add a `nginx.conf` file specifying the service nginx configuration.

For example, core:

```nginx
server {
	server_name $DOMAIN_NAME;

	listen 443 ssl http2;
	listen [::]:443 ssl http2;

	# Redirect dav well-known to SOGo
	rewrite ^/.well-known/caldav  https://mail.$host/SOGo/dav/ permanent;
	rewrite ^/.well-known/carddav https://mail.$host/SOGo/dav/ permanent;
	# For iOS 7
	rewrite ^/principals https://mail.$host/SOGo/dav/ permanent;

	# LemonLDAP /lmauth endpoint.
	include parts.d/sso_endpoint.inc;

	location / {
		# Include conf to protect this endpoint with lemonLDAP.
		include parts.d/sso_protect.inc;

		# Set authentication info using lemonLDAP variables.
		auth_request_set $sso_remote_user $upstream_http_remote_user;
		proxy_set_header Remote-User $sso_remote_user;

		# Necessary to proxy websocket
		proxy_http_version 1.1;
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection "Upgrade";

		# Use resolver and variable to prevent nginx to crash when it does not found the upstream host.
		resolver 127.0.0.11 valid=30s;
		set $upstream_core core;
		proxy_pass http://$upstream_core:9000;
		# Needed so express-session can set a secure cookie
		proxy_set_header X-Forwarded-Proto https;
		# Forward host so express vhost can dispatch to the correct express-session
		proxy_set_header Host $host;
	}
}
```

#### `config/lemon.jq`

You can use this file to integrate the service with [LemonLDAP](https://lemonldap-ng.org/welcome). This is mostly wanted for SSO.

You will also need to configure SSO in the Nginx configuration file.

For example, SOGo uses the Remote-User and Basic Auth to authenticate the user:

```jq
{
	exportedHeaders: {
		"mail.\($domain)": {
			"Remote-User": "$uid",
			"Authorization": "\"Basic \".encode_base64(\"$uid:$_password\", '')"
		}
	},
	locationRules: {
		"mail.\($domain)": {
			default: "accept"
		}
	},
	vhostOptions: {
		"mail.\($domain)": {
			vhostType: $vhostType
		}
	}
}
```

#### `docker-compose.yml`

For the service to be started in `flapctl start`, you must add a `docker-compose.yml` file.

You must specify:

-   the image tag, preferably with a precise subversion.
-   the container name, so it do not depend on the main folder name.
-   the restart strategy, preferably `always`
-   the logging driver, preferably `${LOG_DRIVER:-journald}`.

You can specify:

-   any volumes linked to permanently store data.
-   volumes that nginx need to bind with through the `x-nginx-extra-volumes` property.
-   docker network connection and its hostname.

For example, PostgreSQL:

```yaml
services:
    sogo:
        image: registry.gitlab.com/flap-box/sogo:4.3.0-1
        container_name: flap_sogo
        env_file: [$FLAP_DIR/sogo/sogo.env]
        restart: always
        logging:
            driver: ${LOG_DRIVER:-journald}
        depends_on: [postgres, ldap, memcached]
        volumes:
            - ${FLAP_DIR}/sogo/config/sogo.conf:/etc/sogo/sogo.conf # [emmc] -> [sogo] SOGo's config.
            - ${FLAP_DIR}/sogo/config/stunnel.conf:/etc/stunnel/sogo.conf # [emmc] -> [sogo] Stunnel's config.
            - sogoStaticFiles:/usr/local/lib/GNUstep/SOGo # [sogo] -> [nginx] Static files needed by nginx
        networks:
            stores-net:
            apps-net:
                aliases: [sogo]

volumes:
    sogoStaticFiles:
        name: flap_sogoStaticFiles

x-nginx-extra-volumes:
    - sogoStaticFiles:/usr/local/lib/GNUstep/SOGo:ro # [sogo] -> [nginx] SOGo static files.
```

You can also create `docker-compose.ci.yml` and `docker-compose.override.yml` files. They will be used to override some configuration if respectively, `FLAG_GENERATE_DOCKER_COMPOSE_OVERRIDE` or `FLAG_GENERATE_DOCKER_COMPOSE_CI` are set. They are used during development.

## Hooks

Hooks are called during FLAP life-cycle. They are used to configure the services. From installation to domain name update, it is the place to handle the particularities of the services. During hooks execution, you can make use of any environment variables shown by `flapctl config show`. You can add environment variable with the first hook, `load_env`

Each hook must be placed inside the service's hook directory: `$FLAP_DIR/<service_name>/scripts/hooks/<hook_name>`.

Currently, only shell scripts are allowed.

You must place the hooks in the `<service_name>/scripts/hooks` directory.

Below is the list of hooks you can use:

#### load_env

This hook is used to load environment variables specific to the service. This can be a database password for example. Those variables will be available in all `flapctl` commands, hooks and during templates rendering.

This is the place to populate some special FLAP environment variables.

-   `FLAP_ENV_VARS`: is used to expose variables during script execution and template rendering.
-   `SUBDOMAINS`: is used during TLS certificates generation.
-   `NEEDED_PORTS`: is used during `flapctl ports setup` and `flapctl setup firewall`.

Context:

    -   This hook is called at every `flapctl` calls, do not make long operations here, or cache the result.
    -   Services can either be up or down, do not make any assumptions.

Example:

```shell
#!/bin/bash

set -eu

SUBDOMAINS="$SUBDOMAINS thesubdomain"
NEEDED_PORTS="$NEEDED_PORTS thesubdomain"

FLAP_ENV_VARS="$FLAP_ENV_VARS \${MY_DB_PASSWORD}"

export MY_DB_PASSWORD
MY_DB_PASSWORD=$(generatePassword nextcloud nextcloud_db_pwd)
```

#### should_install

This hook is used to indicate whether or not to install the service. If this hook do not return 0, the service will not be installed.

This can be useful if the service that needs a specific environment to be installed. For example, `matrix` needs to have an attributed domain name before being installed.

You can also create a special variables for the service to enable or disable it.

Context:

    -   This hook is called at every `flapctl` calls, do not make long operations here, or cache the result.
    -   This hook is called to populate the `FLAP_SERVICES` global variable and by the `hooks.sh` script before hooks every execution.
    -   Services can either be up or down, do not make any assumptions.

Example:

```shell
#!/bin/bash

set -eu

# Do not install matrix unless ENABLE_MATRIX is set to true.
test "${ENABLE_MATRIX:-false}" == "true"

# Do not install matrix if MATRIX_DOMAIN_NAME is not set.
test "$MATRIX_DOMAIN_NAME" != ""
```

#### generate_config

This hook is used to let the service generate special configuration file that can not be generate with a template.

For example, matrix use this hook to generate a Nginx configuration file for the `MATRIX_DOMAIN_NAME`.

Context:

    - This hook is ran at every `flapctl start` calls.
    - Services should be down.

Example:

```shell
#!/bin/bash

set -eu

# Add matrix's nginx config to the nginx config folder.
# This is needed because synapse can not be multi-domains.
# So we have to choose a MATRIX_DOMAIN_NAME that will always be the same,
# and generate a nginx config file for that domain only.
echo "Generating Synapse's Nginx configuration."
# shellcheck disable=SC2016
envsubst "$FLAP_ENV_VARS" < "$FLAP_DIR/matrix/config/nginx.conf" > "$FLAP_DIR/nginx/config/conf.d/domains/$MATRIX_DOMAIN_NAME/synapse.conf"

```

#### init_db

This hook is used to let the service run some command to setup the database, like creating a user and a database.

Context:

    - This hook is ran only once during the service's installation phase.
    - This hook is ran during `flapctl start` before services are started.
    - Services should be down.
    - The database will specially be running during this hook so there is no need to start it.

Example:

```shell
#!/bin/bash

set -eu

echo "Creating Synapse user and database in PostgreSQL."
docker-compose exec -T --user postgres postgres psql -v ON_ERROR_STOP=1 <<-EOSQL
	CREATE USER synapse WITH ENCRYPTED PASSWORD '$SYNAPSE_DB_PWD' CREATEDB;
	CREATE DATABASE synapse ENCODING 'UTF8' LC_COLLATE='C' LC_CTYPE='C' template=template0 OWNER synapse;
EOSQL
```

#### pre_install

This hook is used to let the service make any pre-installation adjustments.

This hook is ran only once during the service's installation phase.

Context:

    - This hook is ran only once during the service's installation phase.
    - This hook is ran during `flapctl start` before services are started.
    - Services should be down.

For example, `matrix` needs to generate some files, and this can only be done by running a command in the synapse docker image.

```shell
#!/bin/bash

set -eu

# Generate the synapse config.
echo "Generating Synapse's homserver.yaml configuration file."
docker-compose run -T --rm --no-deps synapse generate

"$FLAP_DIR/system/cli/lib/merge_yaml.sh" \
	"$FLAP_DATA/matrix/synapse/data/homeserver.yaml" \
	"$FLAP_DIR/matrix/config/synapse.yaml"

if [ "${FLAG_SYNAPSE_ALLOW_REGISTRATIONS:-}" == "true" ]
then
	echo "Enable registrations for Synapse."
	"$FLAP_DIR/system/cli/lib/merge_yaml.sh" \
		"$FLAP_DATA/matrix/synapse/data/homeserver.yaml" \
		"$FLAP_DIR/matrix/config/synapse.allow_registrations.yaml"
fi
```

#### wait_ready

This hook is used to wait for the service to be up. Execute whatever commands to check for the service readyness.

Context:

    -   This hook is called after `flapctl start` calls.

Example:

```shell
#!/bin/bash

set -eu

until docker-compose logs nextcloud | grep "NOTICE: ready to handle connections" > /dev/null
do
    echo "Nextcloud is unavailable - sleeping"
    sleep 1
done
```

#### post_install

This hook is used to let the service make any post-installation adjustments.

This hook is ran only once during the service's installation phase.

For example, `nextcloud` runs some configuration with a command inside the docker container.

Context:

    - This hook is ran only once during the service's installation phase.
    - This hook is ran during `flapctl start` after services are started.
    - Services should be up.

Example:

```shell
#!/bin/bash

set -eu

echo "Giving permission to nextcloud user to access file in /data"
docker-compose exec -T nextcloud touch /data/.ocdata
docker-compose exec -T nextcloud chown www-data:www-data /data

echo "Generate config.php with the config."
docker-compose exec -T --user www-data nextcloud /inner_scripts/generate_initial_config.sh
```

#### post_domain_update

This hook is called whenever a domain is added, deleted, or promoted to main domain.

Context:

    - Services should be up.

For example, `lemon` fetches SAML metadatas:

```shell
#!/bin/bash

set -eu

echo "Fetching lemon's SAML metadatas."

# Check certificates with local CA for local domains.
provider=$(cat "$FLAP_DATA/system/data/domains/$PRIMARY_DOMAIN_NAME/provider.txt")
if [ "$provider" == "local" ]
then
	ca_cert=(--cacert /etc/letsencrypt/live/flap/root.cer)
fi

curl "https://auth.$PRIMARY_DOMAIN_NAME/saml/metadata" --output "$FLAP_DATA/lemon/saml/metadata.xml" "${ca_cert[@]}"
```

#### post_update

This hook is called after a FLAP update.

Context:

    - Services should be up.

There is no example yet.

```shell
#!/bin/bash

set -eu
```

## Migrations

On every FLAP update, services' migrations will be ran. This is a good place to update the service's data structure or any other task that can not be done otherwise.

You must place the migrations in the `<service_name>/scripts/migrations` directory.
Migrations are ran before services are restarted.
Migrations will be ran on every FLAP updates until they finish successfully.

For example: `sogo` in its migration `#1` is migrating the database password file to a new standard file location.

```shell
#!/bin/bash

set -eu

echo "* [1] Move sogo_db_password file."
mkdir --parents "$FLAP_DATA/sogo/passwd"
mv "$FLAP_DATA/system/data/sogoDbPwd.txt" "$FLAP_DATA/sogo/passwd/sogo_db_pwd.txt"
```

## Custom docker image

You can specify a custom Dockerfile for the service.
For the image to be built, you can add a `.gitlab-ci.yml` to take advantage of a standardized way to build images for FLAP in Gitlab pipelines.

Example:

```yaml
include:
    # Auto devop
    - template: Auto-DevOps.gitlab-ci.yml
    # Image build script
    - project: flap-box/flap
      file: build_image.yml

variables:
	# Shell script use to generate the image's tag.
    VERSION_SCRIPT:
```

## Cron jobs

You can define recurring tasks in a `<service_name>.cron` file. The commands will be executed from the host and not the container.

Example, Nextcloud use this to regularly to generate file previews and run various tasks:

```shell
*/5 * * * *     docker exec --tty --user www-data flap_nextcloud php -f /var/www/html/cron.php
0   4 * * *     docker exec --tty --user www-data flap_nextcloud php occ preview:pre-generate
```

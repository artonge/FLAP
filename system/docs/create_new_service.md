# FLAP services

---

> [!INFO]
> FLAP services are a collection of scripts and configuration files. This file is a reference of those to help improving a service integration with FLAP.

- [Templates](#templates)
- [Special files](#special-files)
  - [nginx.conf](#ltservicegtnginxconf)
  - [lemon.jq](#ltservicegtconfiglemonjq)
  - [docker-compose.yml](#ltservicegtdocker-composeyml)
  - [variables.yml](#ltservicegtvariablesyml)
- [Hooks](#hooks)
  - [load_env](#load_env)
  - [should_install](#should_install)
  - [generate_config](#generate_config)
  - [init_db](#init_db)
  - [pre_install](#pre_install)
  - [wait_ready](#wait_ready)
  - [post_install](#post_install)
  - [post_domain_update](#post_domain_update)
  - [post_update](#post_update)
  - [pre_backup](#pre_backup)
  - [post_restore](#post_restore)
- [Monitoring](#monitoring)
- [Migrations](#migrations)
- [Custom docker image](#custom-docker-image)
- [Cron jobs](#cron_jobs)

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

- Having up to date configuration files on each starts. This also allows fast experimentation.
- Using the service's configuration file syntax so we do not have to invent a new one.
- Clear visualization of the current service's configurations.

Limits:

- Does not support complex configuration tweaks. For example, matrix needs the `pre_install` hooks to further customize the configuration.

## Special files

<!-- panels:start -->
<!-- div:title-panel -->
### `<service>/nginx.conf`

<!-- div:left-panel -->
If the service needs to be exposed by Nginx you can add a `nginx.conf` file.

The `nginx.conf` file will be copied for each registered domains.

`nginx.conf` file will are also template, so you can use all the environment variables listed by `flapctl config show`. There is also the `$DOMAIN_NAME` variable that will be replaced by each registered domains.

<!-- div:right-panel -->
For example, home:

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
		set $upstream_home home;
		proxy_pass http://$upstream_home:9000;
		# Needed so express-session can set a secure cookie
		proxy_set_header X-Forwarded-Proto https;
		# Forward host so express vhost can dispatch to the correct express-session
		proxy_set_header Host $host;
	}
}
```

<!-- panels:end -->

---
<!-- panels:start -->
<!-- div:title-panel -->
### `<service>/config/lemon.jq`

<!-- div:left-panel -->
You can use this file to integrate the service with [LemonLDAP](https://lemonldap-ng.org/welcome). This is mostly wanted for SSO.

You will also need to configure SSO in the Nginx configuration file.

- [`exportedHeaders` documentation](https://lemonldap-ng.org/documentation/latest/writingrulesand_headers.html#headers)
- [`locationRules` documentation](https://lemonldap-ng.org/documentation/latest/presentation.html?#authorization)
- `vhostOptions` is always the same.


<!-- div:right-panel -->
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

<!-- panels:end -->

---
<!-- panels:start -->
<!-- div:title-panel -->
### `<service>/docker-compose.yml`

<!-- div:left-panel -->
For the service to be started in `flapctl start`, you must add a `docker-compose.yml` file.

You must specify:

- the image tag, preferably with a precise subversion.
- the container name, so it do not depend on the main folder name.
- the restart strategy, preferably `always`
- the logging driver, preferably `${LOG_DRIVER:-journald}`.

You can specify:

- any volumes linked to permanently store data.
- volumes that nginx need to bind with through the `x-nginx-extra-volumes` property.
- docker network connection and its hostname.

You can also create `docker-compose.ci.yml` and `docker-compose.override.yml` files. They will be used to override some configuration if respectively those variables are set:

- `FLAG_GENERATE_DOCKER_COMPOSE_CI`.
- `FLAG_GENERATE_DOCKER_COMPOSE_OVERRIDE`

<!-- div:right-panel -->
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

<!-- panels:end -->

---
<!-- panels:start -->
<!-- div:title-panel -->
### `<service>/variables.yml`

<!-- div:left-panel -->
Services can be customized to tweak their behaviors.

The home GUI contains a form to set those variables. If you add a new variable for a service, make sure to add it to its `variables.yml` file.

Make sure that tweaking the variable won't break the service.

<!-- div:right-panel -->
Example for home:

```yaml
FLAG_DISABLE_ADVANCED_SETTINGS:
    type: boolean
    info: Disable advanced settings.
    group: tweaks
```

<!-- panels:end -->

## Hooks

Hooks are called during FLAP life-cycle. They are used to configure the services. From installation to domain name update, it is the place to handle the particularities of the services. During hooks execution, you can make use of any environment variables shown by `flapctl config show`. You can add environment variable with the first hook, `load_env`

Each hook must be placed inside the service's hook directory: `$FLAP_DIR/<service_name>/scripts/hooks/<hook_name>`.

Currently, only shell scripts are allowed.

You must place the hooks in the `<service_name>/scripts/hooks` directory.

Below is the list of hooks you can use:

---
<!-- panels:start -->
<!-- div:title-panel -->
### load_env

<!-- div:left-panel -->
This hook is used to load environment variables specific to the service. This can be a database password for example. Those variables will be available in all `flapctl` commands, hooks and during templates rendering.

This is the place to populate some special FLAP environment variables.

- `FLAP_ENV_VARS`: is used to expose variables during script execution and template rendering.
- `SUBDOMAINS`: is used during TLS certificates generation.
- `NEEDED_PORTS`: is used during `flapctl ports setup` and `flapctl setup firewall`.

Context:

- This hook is called at every `flapctl` calls, do not make long operations here, or cache the result.
- Services can either be up or down, do not make any assumptions.

<!-- div:right-panel -->
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

<!-- panels:end -->

---
<!-- panels:start -->
<!-- div:title-panel -->
### should_install

<!-- div:left-panel -->
This hook is used to indicate whether or not to install the service. If this hook do not return 0, the service will not be installed.

This can be useful if the service that needs a specific environment to be installed. For example, `matrix` needs to have an attributed domain name before being installed.

You can also create a special variables for the service to enable or disable it.

Context:

- This hook is called at every `flapctl` calls, do not make long operations here, or cache the result.
- This hook is called to populate the `FLAP_SERVICES` global variable and by the `hooks.sh` script before hooks every execution.
- Services can either be up or down, do not make any assumptions.

<!-- div:right-panel -->
Example:

```shell
#!/bin/bash

set -eu

# Do not install matrix unless ENABLE_MATRIX is set to true.
test "${ENABLE_MATRIX:-false}" == "true"

# Do not install matrix if MATRIX_DOMAIN_NAME is not set.
test "$MATRIX_DOMAIN_NAME" != ""
```

<!-- panels:end -->

---
<!-- panels:start -->
<!-- div:title-panel -->
### generate_config

<!-- div:left-panel -->
This hook is used to let the service generate special configuration file that can not be generate with a template.

For example, matrix use this hook to generate a Nginx configuration file for the `MATRIX_DOMAIN_NAME`.

Context:

- This hook is ran at every `flapctl start` calls.
- Services should be down.

<!-- div:right-panel -->
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

<!-- panels:end -->

---
<!-- panels:start -->
<!-- div:title-panel -->
### init_db

<!-- div:left-panel -->
This hook is used to let the service run some command to setup the database, like creating a user and a database.

Context:

- This hook is ran only once during the service's installation phase.
- This hook is ran during `flapctl start` before services are started.
- Services should be down.
- The database will specially be running during this hook so there is no need to start it.

<!-- div:right-panel -->
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

<!-- panels:end -->

---
<!-- panels:start -->
<!-- div:title-panel -->
### pre_install

<!-- div:left-panel -->
This hook is used to let the service make any pre-installation adjustments.

This hook is ran only once during the service's installation phase.

Context:

- This hook is ran only once during the service's installation phase.
- This hook is ran during `flapctl start` before services are started.
- Services should be down.

<!-- div:right-panel -->
For example, `matrix` needs to generate some files, and this can only be done by running a command in the synapse docker image.

```shell
#!/bin/bash

set -eu

# Generate the synapse config.
echo "Generating Synapse's homeserver.yaml configuration file."
docker-compose run -T --rm --no-deps synapse generate
```

<!-- panels:end -->

---
<!-- panels:start -->
<!-- div:title-panel -->
### wait_ready

<!-- div:left-panel -->
This hook is used to wait for the service to be up. Execute whatever commands to check for the service readiness.

Context:

- This hook is called after `flapctl start` calls.

<!-- div:right-panel -->
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

<!-- panels:end -->

---
<!-- panels:start -->
<!-- div:title-panel -->
### post_install

<!-- div:left-panel -->
This hook is used to let the service make any post-installation adjustments.

This hook is ran only once during the service's installation phase.

For example, `nextcloud` runs some configuration with a command inside the docker container.

Context:

- This hook is ran only once during the service's installation phase.
- This hook is ran during `flapctl start` after services are started.
- Services should be up.

<!-- div:right-panel -->
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

<!-- panels:end -->

---
<!-- panels:start -->
<!-- div:title-panel -->
### post_domain_update

<!-- div:left-panel -->
This hook is called whenever a domain is added, deleted, or promoted to main domain.

Context:

- Services should be up.

<!-- div:right-panel -->
For example, `lemon` fetches SAML metadata:

```shell
#!/bin/bash

set -eu

echo "Fetching lemon's SAML metadata."

# Check certificates with local CA for local domains.
provider=$(cat "$FLAP_DATA/system/data/domains/$PRIMARY_DOMAIN_NAME/provider.txt")
if [ "$provider" == "local" ]
then
	ca_cert=(--cacert /etc/letsencrypt/live/flap/root.cer)
fi

curl "https://auth.$PRIMARY_DOMAIN_NAME/saml/metadata" --output "$FLAP_DATA/lemon/saml/metadata.xml" "${ca_cert[@]}"
```

<!-- panels:end -->

---
<!-- panels:start -->
<!-- div:title-panel -->
### post_update

<!-- div:left-panel -->
This hook is called after a FLAP update.

Context:

- Services should be up.

<!-- div:right-panel -->
There is no example yet.

```shell
#!/bin/bash

set -eu
```

<!-- panels:end -->

---
<!-- panels:start -->
<!-- div:title-panel -->
### pre_backup

<!-- div:left-panel -->
This hook is called before a backup. Use this hook to make extra backup tasks.

Context:

- Services are up.

<!-- div:right-panel -->
For example, sogo dump all the users' data into disks.

```shell
#!/bin/bash

set -eu

docker exec --user sogo flap_sogo sogo-tool backup /backup ALL
```

<!-- panels:end -->

---
<!-- panels:start -->
<!-- div:title-panel -->
### post_restore

<!-- div:left-panel -->
This hook is called after a restoration.

Context:

- Services should be up.

<!-- div:right-panel -->
For example, Nextcloud load its database that was dumped to disk in `pre_backup`.

```shell
#!/bin/bash

set -eu

docker exec --user www-data flap_nextcloud php occ maintenance:mode --on

docker exec --user postgres flap_postgres psql --command "DROP DATABASE nextcloud;"
docker exec --user postgres flap_postgres psql --command "CREATE DATABASE nextcloud WITH OWNER nextcloud;"

# shellcheck disable=SC2002
gzip --decompress --stdout "$FLAP_DATA/nextcloud/backup.sql.gz" | docker exec --interactive --user postgres flap_postgres psql --dbname nextcloud

docker exec --user www-data flap_nextcloud php occ maintenance:mode --off
docker exec --user www-data flap_nextcloud php occ maintenance:data-fingerprint
```

<!-- panels:end -->

<!-- panels:start -->
<!-- div:title-panel -->
## Monitoring

<!-- div:left-panel -->
[Extra information](monitoring.md).

FLAP includes a Prometheus and Grafana instance. Services can expose some dashboards, alerts and exporters to populate this system.

- You can add additional monitoring services in `<service>/docker-compose.monitoring.yml`
- You can specify additional Prometheus config here: `$FLAP_DIR/$service/monitoring/prometheus.yml`
- And you can setup alerts here: `$FLAP_DIR/$service/monitoring/alerts.yml`
- Dashboards goes here: `$FLAP_DIR/$service/monitoring/dashboards`

<!-- div:right-panel -->
Example docker-compose.monitoring.yml for Nginx:

```yaml
services:
    nginx:
        networks:
            monitor-net:
                aliases: [nginx]

    nginxexporter:
        image: fish/nginx-exporter:v0.1.1
        container_name: flap_nginxexporter
        command: ["-nginx.scrape_uri=http://nginx/nginx_status"]
        restart: always
        logging:
            driver: ${LOG_DRIVER:-journald}
        expose: [9113]
        networks:
            monitor-net:
                aliases: [nginxexporter]
        labels:
            org.label-schema.group: "monitoring"
```

Example prometheus.yml for System:

```yaml
groups:
  - name: targets
      rules:
          - alert: monitor_service_down
            expr: up == 0
            for: 30s
            labels:
                severity: critical
            annotations:
                summary: "Monitor service non-operational"
                description: "Service {{ $labels.instance }} is down."

  - name: host
      rules:
          - alert: high_cpu_load
            expr: node_load1 > 1.5
            for: 10m
            labels:
                severity: warning
            annotations:
                summary: "Server under high load"
                description: "Docker host is under high load, the avg load 1m is at {{ $value}}. Reported by instance {{ $labels.instance }} of job {{ $labels.job }}."

          - alert: high_memory_load
            expr: (sum(node_memory_MemTotal_bytes) - sum(node_memory_MemFree_bytes + node_memory_Buffers_bytes + node_memory_Cached_bytes) ) / sum(node_memory_MemTotal_bytes) * 100 > 85
            for: 10m
            labels:
                severity: warning
            annotations:
                summary: "Server memory is almost full"
                description: "Docker host memory usage is {{ humanize $value}}%. Reported by instance {{ $labels.instance }} of job {{ $labels.job }}."

          - alert: high_storage_load
            expr: (node_filesystem_size_bytes{fstype="aufs"} - node_filesystem_free_bytes{fstype="aufs"}) / node_filesystem_size_bytes{fstype="aufs"}  * 100 > 85
            for: 10m
            labels:
                severity: warning
            annotations:
                summary: "Server storage is almost full"
                description: "Docker host storage usage is {{ humanize $value}}%. Reported by instance {{ $labels.instance }} of job {{ $labels.job }}."
```

Example alerts.yml for System:


```yaml
scrape_configs:
  - job_name: "nodeexporter"
      scrape_interval: 5s
      static_configs:
          - targets: ["nodeexporter:9100"]

  - job_name: "cadvisor"
      scrape_interval: 5s
      static_configs:
          - targets: ["cadvisor:8080"]

alerting:
    alertmanagers:
        - scheme: http
          static_configs:
              - targets:
                    - "alertmanager:9093"
```

<!-- panels:end -->

<!-- panels:start -->
<!-- div:title-panel -->
## Migrations

<!-- div:left-panel -->
FLAP try to run pending migrations when it starts. But is is not blocking in case of failure. This is a good place to update the service's data structure or any other task that can not be done otherwise.

> [!TIP]
>You must place the migrations in the `<service_name>/scripts/migrations` directory.

<!-- div:right-panel -->
For example: SOGo in its migration `#1` is migrating the database password file to a new standard file location.

```shell
#!/bin/bash

set -eu

echo "* [1] Move sogo_db_password file."
mkdir --parents "$FLAP_DATA/sogo/passwd"
mv "$FLAP_DATA/system/data/sogoDbPwd.txt" "$FLAP_DATA/sogo/passwd/sogo_db_pwd.txt"
```

<!-- panels:end -->

<!-- panels:start -->
<!-- div:title-panel -->
## Custom docker image

<!-- div:left-panel -->
You can specify a custom Dockerfile for the service.

For the image to be built by Gitlab CI, you must create the file `<service>/.gitlab-ci.yml`.

<!-- div:right-panel -->
Example for SOGo:

```yaml
include:
    # Auto devop
  - template: Auto-DevOps.gitlab-ci.yml
    # Image build script
  - project: flap-box/flap
      file: build_image.yml

variables:
    # Double $$ is needed here as gitlab will interpret $(...) as an empty variable.
    VERSION_SCRIPT: echo $$(grep "SOGO_VERSION " Dockerfile | cut -d " "  -f3)-flap.$$(grep "FLAP_VERSION " Dockerfile | cut -d " "  -f3)
```

<!-- panels:end -->

<!-- panels:start -->
<!-- div:title-panel -->
## Cron jobs

<!-- div:left-panel -->
You can define recurring tasks in a `<service_name>.cron` file.

The commands will be executed from the host and not the container.

<!-- div:right-panel -->
Example, Nextcloud use this to regularly generate file previews and run various tasks:

```shell
*/5 * * * *     docker exec --tty --user www-data flap_nextcloud php -f /var/www/html/cron.php
0   4 * * *     docker exec --tty --user www-data flap_nextcloud php occ preview:pre-generate
```

<!-- panels:end -->

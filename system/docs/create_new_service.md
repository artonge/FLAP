# FLAP services

---

> [!INFO]
> FLAP services are a collection of scripts and configuration files. This file is a reference of those to help improving a service integration with FLAP.

- [FLAP services](#flap-services)
  - [Templates](#templates)
  - [Special files](#special-files)
    - [`<service>/nginx.conf`](#servicenginxconf)
    - [`<service>/config/nginx-*-extra.conf`](#serviceconfignginx--extraconf)
    - [`<service>/config/nginx-*-root.conf`](#serviceconfignginx--rootconf)
    - [`<service>/config/lemon.jq`](#serviceconfiglemonjq)
    - [`<service>/docker-compose.yml`](#servicedocker-composeyml)
    - [`<service>/variables.yml`](#servicevariablesyml)
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
  - [Cron jobs](#cron-jobs)

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

`nginx.conf` files are also templates, so you can use all the environment variables listed by `flapctl config show`. There is also the `$DOMAIN_NAME` variable that will be replaced by each registered domains.

<!-- div:right-panel -->

For example, home:

[home/nginx.conf](src/home/nginx.conf ':include :type=code nginx')

<!-- panels:end -->

---

### `<service>/config/nginx-*-extra.conf`

<!-- div:left-panel -->

This kind of files allow the the service to add an extra configuration to nginx.

<!-- div:right-panel -->

For example, Synapse can only be exposed on a single domain, so it can't use the default `nginx.conf` file. Therefore, an `nginx-*-extra.conf` file has been created to only expose synapse on one domain.

[synapse/config/nginx-synapse-extra.template.conf](src/synapse/config/nginx-synapse-extra.template.conf ':include :type=code nginx')

<!-- panels:end -->

---

### `<service>/config/nginx-*-root.conf`

<!-- div:left-panel -->

This kind of files allow the the service to add configuration for the root domain.

<!-- div:right-panel -->

For example, SOGo need adds `.well-known` endpoint to redirect caldav and cardav requests to himself.

[sogo/config/nginx-sogo-dav-root.conf](src/sogo/config/nginx-sogo-dav-root.conf ':include :type=code nginx')

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

For example, Nextcloud setup its SAML integration:

[nextcloud/config/lemon.jq](src/nextcloud/config/lemon.jq ':include :type=code jq')

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

For example, Peertube:

[peertube/docker-compose.yml](src/peertube/docker-compose.yml ':include :type=code yaml')

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

Example for home has a variable to disable the advanced settings panel in the web GUI:

[home/variables.yml](src/home/variables.yml ':include :type=code yaml')

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

For example Funkwhale declares its subdomain and its database password:

[funkwhale/scripts/hooks/load_env.sh](src/funkwhale/scripts/hooks/load_env.sh ':include :type=code bash')

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

For example Matrix won't be installed if the primary domain is not set:

[matrix/scripts/hooks/should_install.sh](src/matrix/scripts/hooks/should_install.sh ':include :type=code bash')

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

For example Mail merge other services' postfix config to build the final config:

[mail/scripts/hooks/generate_config.sh](src/mail/scripts/hooks/generate_config.sh ':include :type=code bash')

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

For example Nextcloud:

[nextcloud/scripts/hooks/init_db.sh](src/nextcloud/scripts/hooks/init_db.sh ':include :type=code bash')

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

[matrix/scripts/hooks/pre_install.sh](src/matrix/scripts/hooks/pre_install.sh ':include :type=code bash')

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

For example Nextcloud wait for some specific log to be:

[nextcloud/scripts/hooks/wait_ready.sh](src/nextcloud/scripts/hooks/wait_ready.sh ':include :type=code bash')

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

For example, Nextcloud fixes the access right on its data dir and run a script that will complet its installation :

[nextcloud/scripts/hooks/post_install.sh](src/nextcloud/scripts/hooks/post_install.sh ':include :type=code bash')

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

[lemon/scripts/hooks/post_domain_update.sh](src/lemon/scripts/hooks/post_domain_update.sh ':include :type=code bash')

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

For example, Peertube updates its SAML plugin:

[peertube/scripts/hooks/post_update.sh](src/peertube/scripts/hooks/post_update.sh ':include :type=code bash')

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

[sogo/scripts/hooks/pre_backup.sh](src/sogo/scripts/hooks/pre_backup.sh ':include :type=code bash')

<!-- panels:end -->

---

<!-- panels:start -->
<!-- div:title-panel -->

### post_restore

<!-- div:left-panel -->

This hook is called after a restoration.

Context:

- Services are not started yet.

<!-- div:right-panel -->

For example, Nextcloud load its database that was dumped to disk in `pre_backup`.

[nextcloud/scripts/hooks/post_restore.sh](src/nextcloud/scripts/hooks/post_restore.sh ':include :type=code bash')

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

[nginx/docker-compose.monitoring.yml](src/nginx/docker-compose.monitoring.yml ':include :type=code yaml')

Example prometheus.yml for System:

[system/monitoring/prometheus.yml](src/system/monitoring/prometheus.yml ':include :type=code yaml')

Example alerts.yml for System:

[system/monitoring/alerts.yml](src/system/monitoring/alerts.yml ':include :type=code yaml')

<!-- panels:end -->

<!-- panels:start -->
<!-- div:title-panel -->

## Migrations

<!-- div:left-panel -->

FLAP try to run pending migrations when it starts. But is is not blocking in case of failure. This is a good place to update the service's data structure or any other task that can not be done otherwise.

> [!TIP]
> You must place the migrations in the `<service_name>/scripts/migrations` directory.

<!-- div:right-panel -->

For example: SOGo in its migration `#1` is migrating the database password file to a new standard file location.

[sogo/scripts/migrations/1.sh](src/sogo/scripts/migrations/1.sh ':include :type=code bash')

<!-- panels:start -->
<!-- div:title-panel -->

## Custom docker image

<!-- div:left-panel -->

You can specify a custom Dockerfile for the service.

For the image to be built by Gitlab CI, you must create the file `<service>/.gitlab-ci.yml`.

<!-- div:right-panel -->

Example for SOGo:

[sogo/.gitlab-ci.yml](src/sogo/.gitlab-ci.yml ':include :type=code yaml')

<!-- panels:end -->

<!-- panels:start -->
<!-- div:title-panel -->

## Cron jobs

<!-- div:left-panel -->

You can define recurring tasks in a `<service_name>.cron` file.

The commands will be executed from the host and not the container.

<!-- div:right-panel -->

Example, Nextcloud use this to regularly generate file previews and run various tasks:

[nextcloud/nextcloud.cron](src/nextcloud/nextcloud.cron ':include :type=code bash')

<!-- panels:end -->

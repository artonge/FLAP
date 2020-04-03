# FLAP services

---

## Special files

#### config/lemon.jq

#### nginx.conf

#### Dockerfile

#### docker-compose.yml

###### docker-compose.ci.yml

###### docker-compose.override.yml

## Hooks

Hooks are called during FLAP life-cycle. They are used to configure the services. From installation to domain name update, it is the place to handle the particularities of the services. During hooks execution, you can make use of any environment variables shown by `flapctl config show`. You can add environment variable with the first hook, `load_env`

Each hook must be placed inside the service's hook directory: `$FLAP_DIR/<service_name>/scripts/hooks/<hook_name>`.

Currently, only shell scripts are allowed.

Below is the list of hooks you can use:

#### load_env

This hook is used to load environment variables specific to the service. This can be a database password for example. Those variables will be available in all `flapctl` commands and during templates rendering.

This is also the pace to tell FLAP that the service requires a special sub-domain name. This will be use during TLS certificates generation.

Context:

    -   Services can either be up or down, do not make any assumptions.
    -   This hook is called at every `flapctl` calls, do not make long operations here, or cache the result.

Example:

```shell
#!/bin/bash

set -eu

# Expand FLAP_ENV_VARS with the service's variables.
# This is necessary for template rendering.
# Please wrap the variable's name with '\${...}'
FLAP_ENV_VARS="$FLAP_ENV_VARS \${MY_VAR}"

# Expand SUBDOMAINS with the service's sub-domain name.
SUBDOMAINS="$SUBDOMAINS thesubdomain"

# Export a variable that will be available during flapctl commands.
# Please use uppercase for the variables names.
# Please declare and assign separately to avoid masking return values: https://github.com/koalaman/shellcheck/wiki/SC2155
export MY_VAR
MY_VAR="my value"
```

#### should_install

This hook is used to indicate whether or not to install the service, meaning to run the `init_db`, `pre_install` and `post_install` hook.

This can be useful if the service needs a specific environment to be installed. For example, `matrix` needs to have an attributed domain name before being installed.

The exit code will be used to determine whether or not the service can be installed.

Context:

    - This hook is ran before services are started.
    - This hook is ran only once during the service's installation phase.

Example:

```shell
#!/bin/bash

set -eu

# Do not install matrix if MATRIX_DOMAIN_NAME is not set.
test "$MATRIX_DOMAIN_NAME" != ""
```

#### generate_config

This hook is used to let the service generate special configuration file that can not be generate by classical means.

For example, matrix use this hook to generate a Nginx configuration files that can not be generated in the classical way.

Context:

    - This hook is ran before services are started.
    - This hook is ran during every `flapctl start` calls.

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

For example, `matrix` needs to generate some files, and this can only be done by running a command with the synapse image.

Context:

    - This hook is ran only once during the service's installation phase.
    - This hook is ran during `flapctl start` before services are started.

Example:

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

#### post_install

#### post_domain_update

#### post_update

## Templates

## Migrations

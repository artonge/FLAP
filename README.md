# FLAP - host your data

---

## Contributing

You can take a look at the tasks board [here](https://gitlab.com/groups/flap-box/-/boards).

## Development setup

FLAP is a composition of services, `nginx`, `postgresql`, `sogo`, etc. They are orchestrated by docker compose.

#### Cloning

`git clone --recursive git@gitlab.com:flap-box/flap.git`

We need the `--recursive` flag so submodules are also cloned.

#### Installing

You can follow the `system/scripts/install_flap.sh` and the `system/cli/cmd/start.sh` scripts to now what needs to be installed and setup.
Or just follow the following paragraphs.

#### Installing dependencies

You need to install the following dependencies in order to run FLAP:

-   [docker](https://docs.docker.com/install)
-   [docker-compose](https://docs.docker.com/compose/install)

I advise to alias the `docker-compose` command to `dc` for ease of use.

#### Installing the manager CLI

The `manager` CLI is a tool to manage a FLAP install. You can install it on your dev machine to ease some procedures.

The following script will:

-   Expose `$FLAP_DIR` and `$FLAP_DATA` as global env variables. You can change them to your convenience.
-   Expose the `manager` CLI tool.

```shell
echo "export FLAP_DIR=/opt/flap" > /etc/environment
echo "export FLAP_DATA=/flap" >> /etc/environment
source /etc/environment
ln -sf $FLAP_DIR/system/cli/manager.sh /bin/manager
```

#### Running services

To start all services you can run:

`manager start`

To start a single service you can run:

`docker-compose up [<service name> ...]`

Dependencies exist between services, which means, for example, that starting `sogo` will also start `postrgres`, `ldap` and `memcached`.

**Warning:** The `nginx` service will bind to the port 80 and 443 of you machine, make sure they are free and that you are allowed to run them.

#### Enabling development settings

Docker-compose [allows overriding](https://docs.docker.com/compose/extends/) the default `docker-compose.yml`. To do that, you can copy the `docker-compose.env.yml` to `docker-compose.override.yml`.

This allow us to redefine services and to run them in a none production mode.

`docker-compose.dev.yml` will do three things:

-   Use local docker images. **Warning**, it means that they will be built, which can take some time.
-   Expose all services to localhost so you can access them directly.
-   Bind the `core` and `manager` directories into their containers and change the start command so you can have live reload when editing local source files.

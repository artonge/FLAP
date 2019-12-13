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

You can follow the `system/scripts/install_flap.sh` script to know what needs to be installed.
Or just follow the following paragraphs.

#### Installing dependencies

You need to install the following dependencies in order to run FLAP locally:

-   [docker](https://docs.docker.com/install)
-   [docker-compose](https://docs.docker.com/compose/install)
- `gettext`
- `jq`
- `psmisc` (for pstree)

I advise to alias the `docker-compose` command to `dc` for ease of use.

#### Installing the flapctl CLI

The `flapctl` CLI is a tool to manage a FLAP install. You can install it on your dev machine to ease some procedures.

The following script will:

-   Expose `$FLAP_DIR` and `$FLAP_DATA` as global env variables. You can change them to your convenience.
-   Expose the `flapctl` CLI tool globally.

```shell
echo "export FLAP_DIR=/opt/flap" > /etc/environment
echo "export FLAP_DATA=/flap" >> /etc/environment
source /etc/environment
ln -sf $FLAP_DIR/system/cli/flapctl.sh /bin/flapctl
```

#### Alias your `localhost` to `flap.localhost`

Adding the following line to your `/etc/hosts` file:

`127.0.0.1   flap.localhost auth.flap.localhost lemon.flap.localhost files.flap.localhost sogo.flap.localhost`


#### Mark the instance as a development one

To inhibit some functionality that are not wanted on a dev machine, please export the `$DEV` environment variable.

```shell
echo "export DEV=true" > /etc/environment
```

#### Running services

To start all services you can run:

```shell
sudo -E flapctl start
```

*For now `sudo` is require to ease the manipulation of containers data. Any proposition to get rid of it is appreciated.*

To start a single service you can run:

```
sudo -E flapctl config generate
docker-compose up [<service name> ...]
```

Dependencies exist between services, which means, for example, that starting `sogo` will also start `postrgres`, `ldap` and `memcached`.

**Warning:** The `nginx` service will bind to the port 80 and 443 of you machine, make sure they are free and that you are allowed to run them.

#### Enabling development settings

Docker-compose [allows overriding](https://docs.docker.com/compose/extends/) the default `docker-compose.yml`. To do that, you can copy the `docker-compose.dev.yml` to `docker-compose.override.yml`.

This allows to redefine services and to run them in a none production mode.

`docker-compose.dev.yml` will do three things:

-   Use local docker images. **Warning**, it means that they will be built, which can take some time.
-   Expose all services to localhost so you can access them directly.
-   Bind the `core` directory to its container and change the start command so you can have live reload when editing local source files.

# Contributing

---

You can take a look at [the tasks board](https://gitlab.com/groups/flap-box/-/boards).

You can also take a look at [feature & roadmap](features.md).

You can also open an issue explaining the modification you would like to make and I will happily help you through the process.

FLAP is a composition of docker services, `nginx`, `postgresql`, `sogo`, etc, orchestrated by docker-compose.

Most of the heavy lifting is done by the [`flapctl` CLI tool](https://gitlab.com/flap-box/flap/-/tree/master/system/cli).

### Cloning

`git clone --recursive git@gitlab.com:flap-box/flap.git`

We need the `--recursive` flag so submodules are also cloned.

### Installing

You can follow the [`install_flap.sh`](https://gitlab.com/flap-box/flap/-/blob/master/system/img_build/userpatches/overlay/install_flap.sh) script to know what needs to be installed.

Or just follow the following paragraphs.

### Installing dependencies

You need to install the following dependencies in order to run FLAP locally:

-   [docker](https://docs.docker.com/install)
-   [docker-compose](https://docs.docker.com/compose/install)
-   `apt install gettext psmisc jq`
-   `pip install yq`

I advise to alias the `docker-compose` command to `dc` for ease of use.

```bash
echo "alias dc='docker-compose'" > ~/.bashrc
```

### Installing the flapctl CLI

The `flapctl` CLI is a tool to manage a FLAP install. You can install it on your dev machine to ease some procedures.

The following script will:

-   Expose `$FLAP_DIR` and `$FLAP_DATA` as global env variables. You can change them to your convenience.
-   Expose the `flapctl` CLI tool globally.

```bash
echo "export FLAP_DIR=/opt/flap" > /etc/environment
echo "export FLAP_DATA=/flap" >> /etc/environment
source /etc/environment
ln -sf $FLAP_DIR/system/cli/flapctl.sh /bin/flapctl
```

### Alias your `localhost` to `flap.test`

Adding the following line to your `/etc/hosts` file:

`127.0.0.1 flap.test auth.flap.test home.flap.test lemon.flap.test monitoring.flap.test files.flap.test mail.flap.test matrix.flap.test chat.flap.test jitsi.flap.test coturn.flap.test`

### ⚠ Setup feature flags

[Extra information](environment_variables.md).

The `flapctl` CLI uses feature flags to inhibit or change some functionality. Copy the `flapctl.example.env` to `$FLAP_DATA/system/flapctl.env` file and setup the variables accordingly. A typical dev station would use most of them.

```bash
cp flapctl.example.env flapctl.env
```

Services can also support specific feature flags. Take a look at `$FLAP_DIR/<service>/variables.yml`.

### Running services

To start all services you can run:

```bash
sudo -E flapctl start
```

_For now `sudo` is required to ease the manipulation of containers data. Any proposition to get rid of it would be appreciated._

To start a single service you can run:

```bash
sudo -E flapctl config generate
docker-compose up [<service name> ...]
```

Dependencies exist between services, which means, for example, that starting `sogo` will also start `postrgres`, `ldap` and `memcached`.

**Warning:** The `nginx` service will bind to the port 80 and 443 of you machine and the mail service will bind the port 25, 143 and 587, make sure they are free and that you are allowed to use them.

### Enabling development settings

Docker-compose [allows overriding](https://docs.docker.com/compose/extends/) the default `docker-compose.yml`. A default `docker-compose.override.yml` is generated with the `FLAG_GENERATE_DOCKER_COMPOSE_OVERRIDE` feature flag. You can tweak the services' own `docker-compose.override.yml` if you need to.

`docker-compose.override.yml` will currently do things like:

-   Use local docker images.
-   Expose all services to `localhost:some_port` so you can access them directly.
-   Bind the `./home` directory to its container and change the start command so you can have live reload when editing local source files.
-   Expose an phpLdapAdmin instance.
-   Activate debug mode on some service.

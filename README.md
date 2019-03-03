# FLAP

---

## Development

FLAP is a composition of services, `nginx`, `mariadb`, `sogo`, etc. They are orchestrated by docker compose.

#### Cloning

`git clone --recursive git@gitlab.com:flap-box/flap.git`

We need the `--recursive` flag so submodules are also cloned.

#### Installing dependencies

You need to install the following dependencies in order to run FLAP:

-   [docker](https://docs.docker.com/install)
-   [docker-compose](https://docs.docker.com/compose/install)

I advise to alias the `docker-compose` command to `dc` for ease of use.

#### Generating certificates

`nginx` will upgrade all connections to HTTPS so you need to generate some certificates on your local machine. Just run the following script:

`system/scripts/generateCerts.sh`

This will generate certs for `flap.localhost` and some sub-domains. You don't need to edit you `/etc/hosts` file because `.localhost` will already redirect to you local machine.

**Warning:** Your browser will show a warning, it is safe to ignore it.

#### Running services

To start service you need to run the following command:

`docker-compose up [<service name> ...]`

Dependencies exist between services, which means, for example, that starting `sogo` will also start `mariadb`, `ldap` and `memcached`.

If you don't specify some services, this will start all services.

**Warning:** The `nginx` service will bind to the port 80 and 443 of you machine, make sure they are free.

#### Enabling development mode

Docker-compose [allows overriding](https://docs.docker.com/compose/extends/) the default `docker-compose.yml`. To do that, you can copy the `docker-compose.env.yml` to `docker-compose.override.yml`.

This allow us to redefine services and to run them in a none production mode.

`docker-compose.dev.yml` will do three things:

-   Use local docker images. **Warning**, it means that they will be built, which can take some time.
-   Expose all services to localhost so you can access them directly.
-   Bind the `core` and `manager` directories into their containers and change the start command so you can have live reload when editing local source files.

## Todos

For each services, you can look at their own README.md file to see what needs to be done.

-   [ ] Automatic build of arm docker images (https://gitlab.com/ulm0/gitlab-runner)
-   [ ] Dynamic setup script with custom domain name
-   [ ] Auto generate SSL certs

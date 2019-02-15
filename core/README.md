# FLAP

---

## Development

FLAP is a composition of services, `nginx`, `mariadb`, `sogo`, etc. They are orchestrated by docker compose.

#### Installing dependencies

You need to install the following dependencies in order to run FLAP:

-   docker
-   docker-compose
-   nodejs >= 10
-   npm

I advise to alias the `docker-compose` command to `dc` for ease of use.

#### Generating certificates

`nginx` will upgrade all connections to HTTPS so you need to generate some certificates on your local machine. Just run the following script:

`system/scripts/generateCerts.sh`

This will generate certs for `flap.localhost` and some sub-domains. You don't need to edit you `/etc/hosts` file because `.localhost` will already redirect to you local machine.

Your browser will show a warning, it is safe to ignore it.

#### Running services

To start service you need to run the following command:

`docker-compose up [<service name> ...]`

Dependencies exist between services, which means that starting `sogo` will also start `mariadb`, `ldap` and `memcached`.

If you don't specify some services, this will start all services.

**Warning:** The `nginx` service will bind to the port 80 and 443 of you machine, make sure they are free.

**Warning:** The first run might take some time as it need to build the images.

#### Allowing direct access to services

By default, only some services are only accessible through the `nginx` container. But it can be useful to have direct access to `mariadb` for example. You can allow direct access by uncommenting the `ports` property of the selected services in the `docker-compose.yml` file and commenting `internal: true` under `networks.stores-net`. Don't forget to not commit this change !

Selected services will then be exposed to `localhost`. Make sure their ports are free to use.

#### Working on core's backend

You can debug the `core` service by uncommenting what is under `DEV MODE` in the `docker-compose.yml` file. This will bind the local `core` directory into the container and change the command so you can have live reload when editing local source files.

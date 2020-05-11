# FLAP - host your data

---

Welcome to the **FLAP** main repository. FLAP main objective is to ease self-hosted services administration to allow more people to manage their numeric data.

![Home page](https://gitlab.com/flap-box/core/raw/master/screenshots/home.png)

---

### FLAP is:

-   A **framework for self-hosted services** administration.
-   An opinionated **selection of self-hosted services**.
-   A **nice web GUI** to access the services and manage users and domain names.

Once installed, most of the heavy lifting is done through the `flapctl` [CLI tool](https://gitlab.com/flap-box/flap/-/tree/master/system/cli).

## Framework features

[More information here](https://gitlab.com/flap-box/flap/-/blob/master/README.services.md)

You can define:

-   **Hooks** called during FLAP life-cycle
    -   database initialization
    -   pre/post installation
    -   load service's specific environment global variables
    -   configuration generation before starting services
    -   wait ready after starting services
    -   post FLAP update
    -   post domain update
-   **Configuration file** with **templates** for:
    -   the service
    -   docker-compose
    -   nginx
    -   lemonLDAP (SSO)
-   **Migrations** which are run after a FLAP update when services are down.
-   **Dockerfile** to automatically build custom docker images in Gitlab pipelines
-   **Cron** tasks

## Available services

Each service is contained in it own directory.

-   **User visible applications:**
    -   FLAP user and admin web GUI
    -   Nextcloud
    -   SOGo
    -   Synapse/Riot
    -   Jitsi
-   **Backend services:**
    -   Nginx
    -   LemonLDAP
    -   OpenLDAP
    -   PostgreSQL
    -   Redis
    -   Memcached
    -   Mail (Dovecot, Postfix, Postgrey, Postscreen, Amavis, SmapAssassin, OpenDKIM, OpenDMARC)

## Administration

FLAP aims to lower the need for administration. This is done by:

-   **Automatic updates.** FLAP uses versions to bring new features and services. It will check daily for new versions from the git repository.

    Services' versions are statically declared in `docker-compose.yml` files. This is done to prevent wild updates.

-   **Limiting FLAP administrators capabilities.** FLAP administrators are not administrators inside the available services. Therefore they do not have a lot of possibility to customize them.

    The logic behind this restriction is as follow:

    Making it easy to make administration level customization for an uninformed user can easily lead to errors. So customization is only possible by going to the CLI level where, I believe, only advanced users will go.

    In the future, it is planed to have a way to enable or disable features for services in the FLAP web GUI. For example: allowing or disabling external registrations in Synapse.

-   **Heavy use of Gitlab pipelines** to tests installation and update processes and to run e2e tests to prevent breakages.

## Installation

[See here.](https://gitlab.com/flap-box/flap/-/blob/master/INSTALL.md)

## Contributing

[See here.](https://gitlab.com/flap-box/flap/-/blob/master/CONTRIBUTING.md)

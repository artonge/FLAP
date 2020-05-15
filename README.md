# FLAP - host your data

---

Welcome to the **FLAP** main repository. FLAP main goal is to ease self-hosted services administration to allow more people to manage their numeric data.

If you need help setting up services, take a look at [our commercial offers](https://www.flap.cloud).

Feel free to come chat on the matrix room: [#flap-software:matrix.org](https://riot.im/app/#/room/#flap-software:matrix.org).

![Home page](https://gitlab.com/flap-box/core/raw/master/screenshots/home.png)

---

### FLAP is:

-   A **framework for self-hosted services** administration.
-   An opinionated **selection of self-hosted services**.
-   A **nice web GUI** to access the services and manage users and domain names.

Once installed, most of the heavy lifting is done by the [`flapctl` CLI tool](https://gitlab.com/flap-box/flap/-/tree/master/system/cli).

## Framework features

[Features & Roadmap](https://gitlab.com/flap-box/flap/-/blob/master/FEATURES.md)

[Detailed list of framework features for services](https://gitlab.com/flap-box/flap/-/blob/master/README.services.md)

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

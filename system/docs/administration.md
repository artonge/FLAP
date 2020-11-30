# Administration

---

FLAP aims to lower the need for administration. This is done by:

-   **Automatic updates.** FLAP uses versions to bring new features and services. It will check daily for new versions from the git repository.

    Services' versions are statically declared in `docker-compose.yml` files. This is done to prevent wild updates.

-   **Limiting FLAP administrators capabilities.** FLAP administrators are not administrators inside the available services. Therefore they do not have a lot of possibility to customize them.

    The logic behind this restriction is as follow:

    Making it easy to make administration level customization for an uninformed user can easily lead to errors. So customization is only possible by going to the CLI level where, I believe, only advanced users will go.

    In the future, it is planed to have a way to enable or disable features for services in the FLAP web GUI. For example: allowing or disabling external registrations in Synapse.

-   **Heavy use of Gitlab pipelines** to tests installation and update processes and to run e2e tests to prevent breakages.

With that say, there is an `admin` user that can log to some service with extra capabilities. Its password can be found by running `flapctl config show`.

> [!NOTE]
> Do not forget to set the `ADMIN_EMAIL` environment variable to receive important mail from you server.

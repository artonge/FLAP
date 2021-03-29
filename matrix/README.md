# Matrix for FLAP

---

### Functionality

-   Synapse server
-   Element web
-   SSO

### Particularities

-   Synapse can not be multi-domains, so we have to choose a MATRIX_DOMAIN_NAME that will always be the same. This means that the nginx config file can not be handled like the other. It is placed in the `config` folder and is the subject of a config step that will generate a fresh nginx config file for the selected domain.

### Contributing

###### Cloning

It is preferable to clone the main project:

`git clone --recursive git@gitlab.com:flap-box/flap.git`

We need the `--recursive` flag so submodules are also cloned.

Then follow the main FLAP `README.md` to setup your workspace.

### Possible improvements

-   List local users
-   [Auto login when user is logged-in](https://github.com/vector-im/element-web/issues/12883)
-   [Logout when logout](https://github.com/matrix-org/synapse/pull/6414)
-   [Use display name](https://github.com/matrix-org/synapse/issues/5763)
-   [Use email](https://github.com/matrix-org/synapse/issues/7023)

###### Resources

-   [Matrix](https://matrix.org)
-   [Synapse repository](https://github.com/matrix-org/synapse)
    -   [Configuration](https://github.com/matrix-org/synapse/blob/master/docs/sample_config.yaml)
    -   [Docker image](https://hub.docker.com/r/matrixdotorg/synapse/)
    -   [Federation tester](https://federationtester.matrix.org/)
    -   [Maintenance](https://github.com/spantaleev/matrix-docker-ansible-deploy/blob/master/docs/maintenance-synapse.md)
-   [Element repository](https://github.com/vector-im/element-web)
    -   [Configuration](https://github.com/vector-im/element-web/blob/develop/docs/config.md)
    -   [Docker image](https://hub.docker.com/r/vectorim/element-web/)
-   [Synapse/Element Ansible](https://github.com/spantaleev/matrix-docker-ansible-deploy)
-   [Monitoring](https://github.com/matrix-org/synapse/blob/b2b86990705de8a099093ec141ad83e09f182034/docs/metrics-howto.md)
    -   [Prometheus](https://github.com/matrix-org/synapse/tree/master/contrib/prometheus)
    -   [Grafana](https://github.com/matrix-org/synapse/tree/master/contrib/grafana)

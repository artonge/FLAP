# Jitsi for FLAP

---

### Functionality

-   Jitsi server for video-conferencing.
-   Coturn server

### Contributing

###### Cloning

It is preferable to clone the main project:

`git clone --recursive git@gitlab.com:flap-box/flap.git`

We need the `--recursive` flag so submodules are also cloned.

Then follow the main FLAP `README.md` to setup your workspace.

### Possible improvements

-   Use SSO to limit server use to authenticated users.
-   Use PostgreSQL and Redis for Coturn

###### Resources

-   [Jitsi](https://meet.jit.si/)
    -   [Docker setup](https://github.com/jitsi/docker-jitsi-meet)
    -   [SSO for Jitsi](https://github.com/jitsi/jicofo/blob/master/doc/shibboleth.md)
    -   [SSO from lemonLDAP](https://lemonldap-ng.org/documentation/latest/applications/jitsimeet?s[]=jitsi)
-   [Coturn repository](https://github.com/coturn/coturn)
    -   [Setup TURN server](https://github.com/matrix-org/synapse/blob/master/docs/turn-howto.md)
    -   [Docker image](https://hub.docker.com/r/instrumentisto/coturn/)
    -   [Test TURN server](https://webrtc.github.io/samples/src/content/peerconnection/trickle-ice/)

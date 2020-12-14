# Nextcloud for FLAP

---

### Functionality

-   Allow users to connect to Nextcloud with the LDAP service.
-   Use SAML for SSO. SAML keys are generated on install in `$FLAP_DATA/netcloud/saml`. SAML metadata are generated on domain names update.
-   Administration possibility are reduce to the minimum to prevent user misuse.
-   Preview generator is installed.
-   It can send mail with the mail service.
-   It uses Redis.
-   Cron jobs are executed by the system.

### Contributing

###### Possible improvements

-   Redirect attempt to connect to Caldav and Carddav services to SOGo to prevent user error ?
-   Connect to a ClamAV instance. The mail service can provide one.
-   Enable end to end encryption ?
-   Expose a default shared folder to the local network.
-   Enable Talk with TURN server ?
-   Enable Talk and bridge it to matrix
-	Fix instance url in mail when a user changes its mail in FLAP

###### Resources

-   [Nextcloud](https://nextcloud.com/)
-   [Source code](https://github.com/nextcloud)
-   [Docker image](https://github.com/nextcloud/docker)

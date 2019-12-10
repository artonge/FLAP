# Nextcloud for FLAP
---
This is base on https://github.com/nextcloud/docker.

### Functionality
- Allow users to connect to Nextcloud with the LDAP service.
- Use SAML for SSO. SAML keys are generated on install in `$FLAP_DATA/netcloud/saml`. SAML metadata are generated on domain names update.
- Administration possibility are reduce to the minimum to prevent user misuse.
- Preview generator is installed.
- It can send mail with the mail service.
- It uses Redis.
- Cron jobs are executed by the system.

### Possible improvements
- Redirect attempt to connect to Caldav and Carddav services to SOGo to prevent user error.
- Connect to a ClamAV instance. The mail service can provide one.
- Enable end to end encryption.
- Enable online collaboration with colabora online.
- Expose a folder to the local network.

# SOGo docker image for FLAP

---

## Functionality

- Expose a GUI for mails, calendars and contact.
- Expose a Caldav and Cardav API.
- SSO connection with Basic Auth header.
- Connect to the mail service.
- Use memcache.

## Possible improvements

- Enable SAML or CAS connection (See issue: https://www.sogo.nu/bugs/view.php?id=5292).

## Contributing
### Changing the configuration

- Tweak the configuration in `./config/sogo.template.conf`.
- Restart the containers.
- Repeat.

### Links

- [Documentation](https://sogo.nu/files/docs/SOGoInstallationGuide.html)

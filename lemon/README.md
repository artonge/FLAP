# LemonLDAP for FLAP

---

This handle all the authentication logic in FLAP.

## Functionality

- SSO login and logout.
- SAML server. SAML keys are generated on install in `$FLAP_DATA/lemon/saml`. SAML metadata are generated on domain names update.
- Services protection with the nginx `auth_request` directive.
- Custom GUI with modern look and tweaked flow in `/skin`. - auto redirect on logout. - redirect to our custom home page.

## Possible improvements

- Allow multi-factor authentication.
- Finish to customize the GUI for edge cases.
- Use redis to store sessions. Right now I can not get it to work.
- Activate the OpenID server, to allow user to authenticate to external service with FLAP.
- Activate the CAS server if needed by a service.

## Known bugs

- SAML authentication can fail some time: https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/issues/1939

## Contributing

### Downloading documentation for lemon.flap.test

```bash
wget https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/archive/master/lemonldap-ng-master.zip
unzip lemonldap-ng-master.zip
mv lemonldap-ng-master/doc ./lemon/doc
rm -rf lemonldap-ng-master
rm -rf lemonldap-ng-master.zip
```

### Changing the configuration

- Tweak the configuration in `./config/lmConf-1.template.json`.
- Tweak any service's configuration in `./<service>/config/lemon.jq`.
- Restart the containers.
- Check that you have what you want.
- If not, repeat.

### Access admin GUI

You can access the admin GUI during development but going to https://lemon.flap.test.

### Changing the skin

Just update the HTML, CSS or JS you want and reload the page.
Templates are located in `./skin/templates`.
Custom CSS and JS are located in `./skin/flapskin`. You can include them in the templates with this kind of paths: `/lemon_flapskin/js/logout_redirect.js`.

Quick tips:

- use `class="section"` around your main content
- use `class="feed-card"` to have a card effect on an element
- use this to center your content.

```html
<div class="col-1-4 space"></div>
<div class="col-1-2">CONTENT</div>
<div class="col-1-4 space"></div>
```

## Updating sources

### Modules

You can use the following ressources to help you apply the patches to the new versions:

- [Merge Request](https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/merge_requests/144)
- [Comparison between versions](https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/compare/v2.0.11...v2.0.12?from_project_id=181&page=8)
- Concerned files:
  - [lib/Lemonldap/NG/Manager/Build/Attributes.pm](https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/blob/master/lemonldap-ng-manager/lib/Lemonldap/NG/Manager/Build/Attributes.pm)
  - [lib/Lemonldap/NG/Manager/Build/PortalConstants.pm](https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/blob/master/lemonldap-ng-manager/lib/Lemonldap/NG/Manager/Build/PortalConstants.pm)
  - [lib/Lemonldap/NG/Portal/Register/AD.pm](https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/blob/master/lemonldap-ng-portal/lib/Lemonldap/NG/Portal/Register/AD.pm)
  - [lib/Lemonldap/NG/Portal/Register/Demo.pm](https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/blob/master/lemonldap-ng-portal/lib/Lemonldap/NG/Portal/Register/Demo.pm)
  - [lib/Lemonldap/NG/Portal/Register/LDAP.pm](https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/blob/master/lemonldap-ng-portal/lib/Lemonldap/NG/Portal/Register/LDAP.pm)
  - [lib/Lemonldap/NG/Portal/Plugins/Register.pm](https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/blob/master/lemonldap-ng-portal/lib/Lemonldap/NG/Portal/Plugins/Register.pm)
  - [site/templates/bootstrap/register.tpl](https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/blob/master/lemonldap-ng-portal/site/templates/bootstrap/register.tpl)

### Templates

You can find the [updated source here](https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/tree/v2.0/lemonldap-ng-portal/site/templates/bootstrap)

There is modifications in the following files:

- `customfooter.tpl` (comment)
- `customheader.tpl` (comment)
- `error.tpl` (wrapper)
- `header.tpl` (comment, title, scripts and styles)
- `info.tpl` (comment and script)
- `login.tpl` (classes, spaces)
- `mail.tpl` (wrapper and classes)
- `menu.tpl` (script)
- `redirect.tpl` (classes)
- `register.tpl` (wrapper, classes, spaces)
- `standardform.tpl` (wrapper, @domain, classes, autocompletes)

## Resources

[Documentation](https://lemonldap-ng.org/documentation/latest/start) -
[Parameter list](https://lemonldap-ng.org/documentation/latest/parameterlist) -
[Repository](https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng)

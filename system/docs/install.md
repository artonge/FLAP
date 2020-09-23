# Installation

---

### Download

First you need to download and run the `install_flap.sh` script.

**Warning:** this script was tested on debian buster only.

This will do the following action, please ensure none of them will break your system:

-   Install apt and pip dependencies needed for `flapctl`
-   Remove postfix dovecot
-   Install docker and docker-compose
-   Enable `unattended-upgrades` and tweak its configuration
-   Override `/etc/environment` with two environment variables
-   Download the FLAP repository on the `/opt/flap` directory
-   Create a simlink for `flapctl` on `/bin/flapctl`
-   Install hooks for letsencrypt
-   Disable password authentication for SSH
-   Create a systemd service for FLAP

Click [here](https://gitlab.com/flap-box/flap/-/raw/master/system/img_build/userpatches/overlay/install_flap.sh) to see the script file.

```shell
echo "Getting and running flap_install.sh script."
curl https://gitlab.com/flap-box/flap/-/raw/master/system/img_build/userpatches/overlay/install_flap.sh | bash

echo "Loading new environment variables."
source /etc/environment
```

### Configuration file

`flapctl` uses two environment variables `FLAP_DIR` and `FLAP_DATA` set in `/etc/environment`.

-   `FLAP_DIR` is where the FLAP repository is. The default is `/opt/flap`.
-   `FLAP_DATA` is where all your data and configuration are. Be careful with this directory ! The default is `/flap`.

`flapctl` also load environment variables from `$FLAP_DATA/system/flapctl.env`. This file is used to store configuration and feature flags options.

You can find examples for:

-   [VPS](https://gitlab.com/flap-box/flap/-/tree/master/system/flapctl.examples.d/vps.env)
-   [Home server](https://gitlab.com/flap-box/flap/-/tree/master/system/flapctl.examples.d/xu4.env)
-   [Local development](https://gitlab.com/flap-box/flap/-/tree/master/system/flapctl.examples.d/local.env)
-   [Gitlab pipelines (development)](https://gitlab.com/flap-box/flap/-/tree/master/system/flapctl.examples.d/pipeline.env)

You can find more information on configuration options:

-   [Administration](https://gitlab.com/flap-box/flap/-/blob/master/system/docs/administration.md)
-   [Feature flags](https://gitlab.com/flap-box/flap/-/blob/master/system/docs/feature_flags.md)
-   [Backup](https://gitlab.com/flap-box/flap/-/blob/master/system/docs/backup.md)
-   [Storage](https://gitlab.com/flap-box/flap/-/blob/master/system/docs/storage.md)

### First start

You can now start FLAP for the first time:

```shell
flapctl start
```

If you are on the same network than your server, you can go to http://flap.local to finish the installation. Else you will need to finish the setup in the terminal to setup your domain name and create the first user.

### Domain name

The domain name setup logic is still young so you will have to set your DNS records by yourself. Ideally FLAP will be able to configure DNS records for some domain name provider. You should, at minimum, have the following records:

```
@    IN    A       <ip>
*    IN    A       <ip>
```

After the DNS records setup, you setup the domain in FLAP in the web GUI or by running the following commands:

```shell
flapctl domains add <you_domain_name>
```

When the domain name is set, you can add the following records for email to work:

```
@                              IN    MX     10    @
@                              IN    TXT    "v=spf1 a aaaa mx -all"
_dmarc                         IN    TXT    "v=DMARC1; p=none"
mail._domainkey                IN    TXT    <dkim>

; extra records to ease email client setup:
_caldavs._tcp       IN    SRV    0    1    443    mail
_carddavs._tcp      IN    SRV    0    1    443    mail
_imap._tcp          IN    SRV    0    1    143    @
_submission._tcp    IN    SRV    0    1    587    @
```

DKIM can be found on the FLAP home web GUI.

# First user

To setup the first user, you can use the web GUI or run the following command:

```shell
flapctl users create
```

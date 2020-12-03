# Installation

---

## Requirements

### Hardware

For small instances serving 5 users and running 3 services, FLAP can run on low powered hardware like the odroid XU4 which has an armvhf 8 core processor and 2Go of RAM. Just add 2Go of swap and you should be good to go.

> [!WARNING]
> Not all services can run on an armvhf computer as docker images are not available for this architecture.

If you want to serve more users or add more services you will have to upgrade your hardware accordingly. As it all depends on the number of user, and how mutch they use the instance, I can't give a specific recomandation.

But as all services are run on a single machine, they won't scale well to thousands of users.

In theory, and with some tweaks, it should be possible to convert the final docker-compose to a Kubernetes config file. This would allow to support a very large number of users as most services can scale horizontaly.

### Network

You can run FLAP behind a NAT given that your router can forward ports. FLAP will use `upnpc` to open the needed ports automatically.

Preventing FLAP to access the internet is not supported but should be possible. There is support to generate ssl certificates with `openssl` for development. You will just need to import the root certificate into your browser to remove SSL warning, and maybe tweak some services configuration like synapse, to informe them that they won't be able to connect to the internet.

## Download

First you need to download and run the `install_flap.sh` script.

> [!WARNING]
> **This script was tested on debian buster only.**

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

[Click here to see the script file.](https://gitlab.com/flap-box/flap/-/raw/master/system/img_build/userpatches/overlay/install_flap.sh)

```bash
echo "Getting and running flap_install.sh script."
curl https://gitlab.com/flap-box/flap/-/raw/master/system/img_build/userpatches/overlay/install_flap.sh | bash

echo "Loading new environment variables."
source /etc/environment
```

## Configuration file

`flapctl` uses two environment variables `FLAP_DIR` and `FLAP_DATA` set in `/etc/environment`.

-   `FLAP_DIR` is where the FLAP repository is. The default is `/opt/flap`.
-   `FLAP_DATA` is where all your data and configuration are. Be careful with this directory ! The default is `/flap`.

`flapctl` also load environment variables from `$FLAP_DATA/system/flapctl.env`. This file is used to store configuration and feature flags options.

You can find examples for:

-   [VPS](https://gitlab.com/flap-box/flap/-/tree/master/system/flapctl.examples.d/vps.env)
-   [Home server](https://gitlab.com/flap-box/flap/-/tree/master/system/flapctl.examples.d/xu4.env)
-   [Local (development)](https://gitlab.com/flap-box/flap/-/tree/master/system/flapctl.examples.d/local.env)
-   [Gitlab pipelines (development)](https://gitlab.com/flap-box/flap/-/tree/master/system/flapctl.examples.d/pipeline.env)

You can find more information on configuration options:

-   [Administration](administration.md)
-   [Feature flags](environment_variables.md)
-   [Backup](backup.md)

## First start

You can now start FLAP for the first time:

```bash
flapctl start
```

- If you are on the same network than your server: go to http://flap.local.
- If your server is not on your network, you will need to setup your domain name and the first user in the terminal.

## Set the domain name

The domain name setup logic is still young so you will have to set your DNS records by yourself. Ideally FLAP will be able to configure DNS records for some domain name provider. You should, at minimum, have the following records:

```
@    IN    A       <ip>
*    IN    A       <ip>
```

After the DNS records setup, you setup the domain in FLAP in the web GUI or by running the following commands:

```bash
flapctl domains add <you_domain_name>
```

When the domain name is set, you can add the following records for email to work:

DKIM can be found on the FLAP home web GUI.

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

## Create the first user

To setup the first user, you can use the web GUI or run the following command:

```bash
flapctl users create
```

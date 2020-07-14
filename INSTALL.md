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
-   Download the FLAP repository on the /flap/opt directory
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

`flapctl` uses two environment variables `FLAP_DIR` and `FLAP_DATA`.

-   `FLAP_DIR` is where the FLAP repository is. This default to `/opt/flap`.
-   `FLAP_DATA` is where all your data and configuration are. Be careful with this directory ! This default to `/flap`.

You will you need to create a `flap_init_config.yml` file inside `FLAP_DIR`. This file will contains information that `flapctl` will use to create the `$FLAP_DATA/flapctl.env` file and configure you host. You can find sample file [here](https://gitlab.com/flap-box/flap/-/tree/master/system/plaforms_init_config) or use the following template:

```yaml
# FEATURES FLAG.
# You can uses features flag to tweak how flapctl works.
# Take a look at flapctl.example.env for the full list feature flags.
# Each services can make use of feature flag as well. You can check each services flags.env files.
env_vars:
    FLAG_NO_NAT_NETWORK_SETUP: ...
    FLAG_DISK_MODE_SINGLE: ...
    FLAG_DISK_MODE_RAID1: ...
    ...: ...

# DISKS SETUP.
# FLAP can automatically setup you disks.
# If you do not set FLAG_DISK_MODE_SINGLE or FLAG_DISK_MODE_RAID1, FLAP will simply store the data on you system disk.
# Warning 1: this is only mean for empty disks as it will delete everything.
# Warning 2: the code is young and not feature full, better check it out to understand what it does (See disks.sh).
# Do not hesitate to submit a merge request to support your disk configuration.

# Paired with FLAG_DISK_MODE_SINGLE=true, FLAP will mount the disk /dev/sda on $FLAP_DATA to store the data.
disks:
    - /dev/sda

# FLAP will attempt to map disks from the server's USB ports.
# Paired with FLAG_DISK_MODE_RAID1=true, FLAP will setup a RAID1 array with the mapped disks.
disks_path:
    - /sys/bus/usb/drivers/usb/4-1.1/4-1.1\:1.0/host0/target0\:0\:0/0\:0\:0\:0/block
    - /sys/bus/usb/drivers/usb/4-1.2/4-1.2\:1.0/host1/target1\:0\:0/1\:0\:0\:0/block

# ADMIN EMAIL.
# FLAP will send you some e-mail if necessary.
# For example in case of disk or RAID array failure
admin_email: <your email>
```

### First account and domain name

The domain name setup logic is still young so you will have to set your DNS records by yourself. Ideally FLAP will be able to configure DNS records for some domain name provider. You should, at minimum, have the following records:

```
@    IN    A       <ip>
*    IN    A       <ip>
```

And for email to work:

```
@                              IN    MX     10    @
@                              IN    TXT    "v=spf1 a aaaa mx -all"
_dmarc                         IN    TXT    "v=DMARC1; p=none"
mail._domainkey                IN    TXT    <dkim>
```

If you are on the same network than your server, you can go to http://flap.local.

Else you will need to finish the setup in the terminal to setup your domain name and create the first user.

```shell
echo "Starting FLAP."
flapctl start
echo "FLAP is up."

echo "Setting up domain name."
flapctl domains add <you_domain_name>
echo "Domain name is set."

echo "Creating first user."
flapctl users create
echo "First user is created."

echo "Restarting FLAP."
flapctl restart
echo "FLAP is UP and ready."
```

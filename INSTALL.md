# Installation

---

First you need to download and run the `install_flap.sh` script. This will download and setup all FLAP dependencies.

```shell
FLAP_VERSION=v1.7.0

echo "Installing FLAP version $FLAP_VERSION."

echo "Getting flap_install.sh script."
wget https://gitlab.com/flap-box/flap/-/raw/$FLAP_VERSION/system/img_build/userpatches/overlay/install_flap.sh
chmod +x /root/install_flap.sh

echo "Running flap_install.sh."
/root/install_flap.sh "$FLAP_VERSION"

echo "Loading new environment variables."
source /etc/environment
```

Next you need to create you `flap_init_config.yml` file. This file will contains information that the `flapctl` tool will use to configure you host. You can find sample file [here](https://gitlab.com/flap-box/flap/-/tree/master/system/plaforms_init_config):

You can now run the following script. It will setup your domain name and create the first user.

```shell
echo "Starting FLAP."
flapctl start
echo "FLAP is up."

echo "Setting up domain name."
wget \
    --method POST \
    --header 'Host: flap.local' \
    --header 'Content-Type: application/json' \
    --body-data "{ \"name\": \"$DOMAIN_NAME\", \"provider\": \"flap\", \"authentication\": \"$FLAP_ID_TOKEN\" }" \
    --quiet \
    --output-document=- \
    --content-on-error \
    "http://localhost/api/domains"

echo "Handling new domain request."
flapctl domains handle_request
echo "Domain name is set."

flapctl hooks wait_ready mail

echo "Creating first user."
wget \
    --method POST \
    --header "Host: flap.local" \
    --header 'Content-Type: application/json' \
    --body-data "{
        \"fullname\": \"$CUSTOMER_NAME\",
        \"email\": \"$CUSTOMER_EMAIL\",
        \"admin\": true
    }" \
    --quiet \
    --output-document=- \
    --content-on-error \
    "http://localhost/api/users"

echo "First user is created."

echo "Restarting FLAP."
flapctl restart
echo "FLAP is UP and ready."
```

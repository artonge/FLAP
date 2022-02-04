#!/bin/bash

set -euo pipefail


get_saml_metadata lemon "$PRIMARY_DOMAIN_NAME" "https://auth.$PRIMARY_DOMAIN_NAME/saml/metadata"

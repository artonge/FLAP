#!/bin/bash

set -eu

get_saml_metadata peertube "$PEERTUBE_DOMAIN_NAME" "https://video.$PEERTUBE_DOMAIN_NAME/plugins/auth-saml2/router/metadata.xml"

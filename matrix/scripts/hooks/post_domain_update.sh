#!/bin/bash

set -eu

get_saml_metadata matrix "$MATRIX_DOMAIN_NAME" "https://matrix.$MATRIX_DOMAIN_NAME/_synapse/client/saml2/metadata.xml"

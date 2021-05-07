#!/bin/bash

set -eu

# Version 1.14.7

echo "* [5] Update Synapse's SAML metadata."
flapctl exec matrix hooks/post_domain_update

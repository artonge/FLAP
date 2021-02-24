#!/bin/bash

set -eu

# Version 1.14.6

echo "* [4] Update Synapse's SAML metadata."
sudo -E flapctl exec matrix hooks/post_domain_update

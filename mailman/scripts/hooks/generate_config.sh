#!/bin/bash

set -eu

echo "$FLAP_DIR/mailman/config/core/postfix-main-extra.cf" > "$FLAP_DIR/mail/config/postfix-main.cf"
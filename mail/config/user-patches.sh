#!/bin/bash

set -euo pipefail


# Create hash file for the smtpd_sender map.
postmap /tmp/docker-mailserver/smtpd_sender

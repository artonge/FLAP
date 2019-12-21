#!/bin/bash

set -eu

# Create hash file for the smtpd_sender map.
postmap /tmp/docker-mailserver/smtpd_sender

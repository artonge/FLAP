#!/bin/bash

set -e

# SETUP THE DATABASE
docker-compose exec --user mastodon mastodon rails db:setup

# CLOSE REGISTRATIONS
docker-compose exec --user mastodon mastodon tootctl settings registrations close

#!/bin/bash

set -euo pipefail

echo STOPPING and CLEANING
mkdir -p /flap/system
touch /flap/system/flapctl.env

flapctl stop
flapctl clean data -y

echo RESTORING
mkdir -p /flap/system
touch /flap/system/flapctl.env
flapctl backup restore

echo UPDATING
flapctl update

echo BACKUPING
flapctl backup

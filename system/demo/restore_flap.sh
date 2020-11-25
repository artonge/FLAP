#!/bin/bash

set -eu

echo STOPING and CLEANING
mkdir -p /flap/system
touch /flap/system/flapctl.env

flapctl stop
flapctl clean data -y

echo RESTORING
mkdir -p /flap/system
touch /flap/system/flapctl.env
flapctl backup restore

echo STARTING
flapctl start

echo UPDATING
flapctl update

echo BACKUPING
flapctl backup

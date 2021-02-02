#!/bin/bash

set -eu

# Version v1.14.3

echo "* [22] Update docker-compose if it was installed with pip."
if pip3 list | grep docker-compose
then
	pip3 install -U docker-compose
fi

echo "* [22] Update docker if it was installed with apt."
apt install --only-upgrade containerd.io docker-ce docker-ce-cli

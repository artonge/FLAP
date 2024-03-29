#!/bin/bash

set -euo pipefail

# Version v1.14.4

echo "* [22] Update docker-compose if it was installed with pip."
if pip3 list | grep docker-compose
then
	python -m pip install -U pip
	pip install -U docker-compose
fi

echo "* [22] Update docker if it was installed with apt."
apt install -y --only-upgrade containerd.io docker-ce docker-ce-cli

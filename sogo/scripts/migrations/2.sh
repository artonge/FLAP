#!/bin/bash

set -euo pipefail


echo "* [2] Run post_install hook."
flapctl hooks post_install sogo

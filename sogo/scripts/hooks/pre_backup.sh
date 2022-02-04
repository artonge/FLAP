#!/bin/bash

set -euo pipefail


docker exec --user sogo flap_sogo sogo-tool backup /backup ALL

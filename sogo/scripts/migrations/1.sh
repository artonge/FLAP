#!/bin/bash

set -euo pipefail


echo "* [1] Move sogo_db_password file."
mkdir --parents "$FLAP_DATA/sogo/passwd"
mv "$FLAP_DATA/system/data/sogoDbPwd.txt" "$FLAP_DATA/sogo/passwd/sogo_db_pwd.txt"

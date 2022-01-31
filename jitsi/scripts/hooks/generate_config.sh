#!/bin/bash

set -euo pipefail

# Add SSO auth for jicofo.
# jicofo_config="$FLAP_DATA/jitsi/jicofo/sip-communicator.properties"
# if [ -f "$jicofo_config" ]
# then
# 	if [ ! -f "$jicofo_config.bak" ]
# 	then
# 		cp "$jicofo_config" "$jicofo_config.bak"
# 	fi
#
# 	cat "$jicofo_config.bak" > "$jicofo_config"
# 	echo "org.jitsi.jicofo.auth.URL=shibboleth:default" >> "$jicofo_config"
# 	echo "org.jitsi.jicofo.auth.LOGOUT_URL=/logout/" >> "$jicofo_config"
# fi

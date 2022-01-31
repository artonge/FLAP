#!/bin/bash

set -euo pipefail


debug "Copy dashboard to grafana directory."
rm -rf "$FLAP_DIR/monitoring/config/grafana/dashboards"
mkdir -p "$FLAP_DIR/monitoring/config/grafana/dashboards"
for service in $FLAP_SERVICES
do
    if [ ! -d "$FLAP_DIR/$service/monitoring/dashboards" ]
    then
        continue
    fi

    cp "$FLAP_DIR/$service/monitoring/dashboards/"* "$FLAP_DIR/monitoring/config/grafana/dashboards"
done


debug "Merge services' prometheus.yml files."
prometheus_files=()

for service in $FLAP_SERVICES
do
	if [ -f "$FLAP_DIR/$service/monitoring/prometheus.yml" ]
	then
		prometheus_files+=("$FLAP_DIR/$service/monitoring/prometheus.yml")
	fi
done

debug "Merge services' scrape_configs properties."
# shellcheck disable=SC2016
scrape_configs=$(
	yq \
		--slurp \
		'reduce .[] as $service ([]; . + $service["scrape_configs"])' \
		"${prometheus_files[@]}"
)

debug "Insert scrape_configs into final the prometheus.yml file."
# shellcheck disable=SC2016
yq \
	--yaml-output \
	--yaml-roundtrip \
	--slurp \
	--argjson scrape_configs "$scrape_configs" \
	'.[0] * {"scrape_configs": $scrape_configs}' \
	"$FLAP_DIR/monitoring/monitoring/prometheus.yml" > "$FLAP_DIR/monitoring/config/prometheus/prometheus.yml"


debug "Merge services' alert.rules files."
alert_files=()

for service in $FLAP_SERVICES
do
	if [ -f "$FLAP_DIR/$service/monitoring/alerts.yml" ]
	then
		alert_files+=("$FLAP_DIR/$service/monitoring/alerts.yml")
	fi
done

debug "Merge services' groups properties."
# shellcheck disable=SC2016
groups=$(
	yq \
		--slurp \
		'reduce .[] as $service ([]; . + $service["groups"])' \
		"${alert_files[@]}"
)

debug "Insert groups into final the alerts.rules file."
# shellcheck disable=SC2016
echo '[]' | yq \
	--yaml-output \
	--yaml-roundtrip \
	--slurp \
	--argjson groups "$groups" \
	'{"groups": (.[0] + $groups)}' > "$FLAP_DIR/monitoring/config/prometheus/alert.rules"

#!/bin/bash

set -eu

echo "Copy dashboard to grafana directory."
rm -rf "$FLAP_DIR/monitoring/config/grafana/dashboards"
mkdir -p "$FLAP_DIR/monitoring/config/grafana/dashboards"
for service in $FLAP_SERVICES
do
    if [ ! -d "$FLAP_DIR/$service/monitoring/dashboards" ]
    then
        continue
    fi

    echo "- $service"
    ls "$FLAP_DIR/$service/monitoring/dashboards"

    cp "$FLAP_DIR/$service/monitoring/dashboards/"* "$FLAP_DIR/monitoring/config/grafana/dashboards"
done


echo "Merge services' prometheus.yml files."
prometheus_files=()

for service in $FLAP_SERVICES
do
	if [ -f "$FLAP_DIR/$service/monitoring/prometheus.yml" ]
	then
		echo "- $service"
		prometheus_files+=("$FLAP_DIR/$service/monitoring/prometheus.yml")
	fi
done

echo "Merge services' scrape_configs properties."
# shellcheck disable=SC2016
scrape_configs=$(
	yq \
		--slurp \
		'reduce .[] as $service ([]; . + $service["scrape_configs"])' \
		"${prometheus_files[@]}"
)

echo "Insert scrape_configs into final the prometheus.yml file."
# shellcheck disable=SC2016
yq \
	--yaml-output \
	--yaml-roundtrip \
	--slurp \
	--argjson scrape_configs "$scrape_configs" \
	'.[0] * {"scrape_configs": $scrape_configs}' \
	"$FLAP_DIR/monitoring/monitoring/prometheus.yml" > "$FLAP_DIR/monitoring/config/prometheus/prometheus.yml"


echo "Merge services' alert.rules files."
alert_files=()

for service in $FLAP_SERVICES
do
	if [ -f "$FLAP_DIR/$service/monitoring/alerts.yml" ]
	then
		echo "- $service"
		alert_files+=("$FLAP_DIR/$service/monitoring/alerts.yml")
	fi
done

echo "Merge services' groups properties."
# shellcheck disable=SC2016
groups=$(
	yq \
		--slurp \
		'reduce .[] as $service ([]; . + $service["groups"])' \
		"${alert_files[@]}"
)

echo "Insert groups into final the alerts.rules file."
# shellcheck disable=SC2016
echo '[]' | yq \
	--yaml-output \
	--yaml-roundtrip \
	--slurp \
	--argjson groups "$groups" \
	'{"groups": (.[0] + $groups)}' > "$FLAP_DIR/monitoring/config/prometheus/alert.rules"

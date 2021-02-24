# Monitoring FLAP services

---

FLAP include a way to monitor running services with [Grafana](https://grafana.com/) and [Prometheus](https://prometheus.io).

Each services can includes dashboards, alert rules, and exporters to populates the monitoring system.

## Enabling monitoring

To enable monitoring you need to set `ENABLE_MONITORING` to true in `$FLAP_DATA/system/flapctl.env`.

## Accessing Grafana

Grafana is accessible at `monitoring.$your_domain`.

You can log in with the username `admin` and the `ADMIN_PWD` password. You can find this password with `flapctl config show`.

## Alerts

Alerts are send by mail to the `ADMIN_EMAIL`.

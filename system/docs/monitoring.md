# Monitoring FLAP services

---

FLAP include a way to monitor running services with [Grafana](https://grafana.com/) and [Prometheus](https://prometheus.io).

Each services can includes dashboards, alert rules, and exporters to populates the monitoring system.

### Enabling monitoring

To enable monitoring you need to set `ENABLE_MONITORING` to true in `$FLAP_DATA/flapctl.env`.
This can also be set before the installation of FLAP in `$FLAP_DIR/flap_init_config.yaml`.

### Accessing Grafana

Grafana is accessible on the `monitoring` sub-domain. You can log in with the username `admin` and the `ADMIN_PWD` password. You can find this password with `flapctl config show`.

### Alerts

Alerts are send by mail to the admin email set in `$FLAP_DATA/system/admin_email.txt`.

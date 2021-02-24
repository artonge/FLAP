# Tweaking FLAP with environment variables flags

---

<!-- panels:start -->
<!-- div:left-panel -->
FLAP can be tweaked using features flags in `$FLAP_DATA/system/flapctl.env`.

Take a look at the services' `variables.yml` files for the full list feature flags.

You can find examples for:

- [VPS](https://gitlab.com/flap-box/flap/-/tree/master/system/flapctl.examples.d/vps.env)
- [Home server](https://gitlab.com/flap-box/flap/-/tree/master/system/flapctl.examples.d/xu4.env)
- [Local (development)](https://gitlab.com/flap-box/flap/-/tree/master/system/flapctl.examples.d/local.env)
- [Gitlab pipelines (development)](https://gitlab.com/flap-box/flap/-/tree/master/system/flapctl.examples.d/pipeline.env)

<!-- div:right-panel -->
Example:

```bash
export ADMIN_EMAIL=<you_email>

export ENABLE_MONITORING=true
export ENABLE_PEERTUBE=true
export ENABLE_NEXTCLOUD=false

export BACKUP_TOOL=restic
export RESTIC_REPOSITORY=/backup
export RESTIC_PASSWORD=<you_password>
```

<!-- panels:end -->

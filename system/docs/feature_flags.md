# Tweaking FLAP with feature flags

---

FLAP can be tweaked using features flags.

They can be set before the installation of FLAP in `$FLAP_DIR/flap_init_config.yaml` or after the installation manually in `$FLAP_DATA/flapctl.env`.

Take a look at `flapctl.example.env` for the full list feature flags.

Each services can also make use of feature flag as well. You can check each services' `flags.env` files.

### Example

```yaml
env_vars:
    FLAG_NO_NAT_NETWORK_SETUP: ...
    FLAG_DISK_MODE_SINGLE: ...
    FLAG_DISK_MODE_RAID1: ...
```

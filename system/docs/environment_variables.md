# Tweaking FLAP with environment variables flags

---

FLAP can be tweaked using features flags in `$FLAP_DATA/system/flapctl.env`.

Take a look at the services' `variables.yml` files for the full list feature flags.

### Example

```bash
export FLAG_DISK_MODE_SINGLE=true
export FLAG_NO_NAT_NETWORK_SETUP=true
export RESTIC_REPOSITORY=/backup
export RESTIC_PASSWORD=secure_password
```

# Setting up backup and restore logic

---

FLAP support [borg](https://www.borgbackup.org/) and [restic](https://restic.readthedocs.io) to backup the `FLAP_DATA` directory. Backups are incrementally made, with a backup retention of:

-   7 daily
-   5 weekly
-   12 monthly

FLAP supports borg and restic to cover most use cases.

-   Borg is more suited to backup servers with low ressources like RPi or Odroids.
-   Restic is ressources intensive, but can backup to a lot of backends like S3 buckets

### Backup hooks

Some services can have a `pre_backup` and `post_restore` hook to extend the backups capability.

### Enable backups

To enable backups you need to setup some environment variables in the `$FLAP_DATA/flapctl.env` file.

This config can also be set before the installation of FLAP in `$FLAP_DIR/flap_init_config.yaml`.

The following examples will backup you `FLAP_DATA` in the `/backup` directory. Make sure that `/backup` has enough space to store your backups.

Make also sure to keep note of your password. You will need it when restoring the data.

##### Borg

```yaml
env_vars:
    BACKUP_TOOL: borg
    BORG_REPO: /backup
    BORG_PASSPHRASE: <you_password>
```

##### Restic

For other backend, the liste of restic's environment variables can be find on [restic documentation](https://restic.readthedocs.io/en/stable/040_backup.html#environment-variables).

`flap_init_config.yaml` version:

```yaml
env_vars:
    BACKUP_TOOL: restic
    RESTIC_REPOSITORY: /backup
    RESTIC_PASSWORD: <you_password>
```

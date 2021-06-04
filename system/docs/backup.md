# Setting up backup and restore logic

---

FLAP support [borg](https://www.borgbackup.org/) and [restic](https://restic.readthedocs.io) to backup the `FLAP_DATA` directory.

> [!TIP]
>
> - **Borg** is more suited to backup servers with low resources like RPi or Odroids.
> - **Restic** is resources intensive, but can backup to a lot of backends like S3 buckets

Backups are incrementally made, with a backup retention of:

- 7 daily
- 5 weekly
- 12 monthly

## Enable backups

To enable backups you need to setup some environment variables in the `$FLAP_DATA/system/flapctl.env` file.

The following examples will backup you `FLAP_DATA` in the `/backup` directory.

Make sure that `/backup` has enough space to store your backups.

Make also sure to keep note of your password. You will need it when restoring the data.

### Borg

```bash
export BACKUP_TOOL=borg
export BORG_REPO=/backup
export BORG_PASSPHRASE=<you_password>
```

### Restic

For other backend, the list of restic's environment variables can be find on [restic documentation](https://restic.readthedocs.io/en/stable/040_backup.html#environment-variables).

```bash
export BACKUP_TOOL=restic
export RESTIC_REPOSITORY=/backup
export RESTIC_PASSWORD=<you_password>
```

## Backup hooks

Some services have a `pre_backup` and `post_restore` hook to extend the backups capability.

## Restoring

To restore a backup on a fresh server, follow the following instructions:

- Run the FLAP install script:

```bash
curl https://gitlab.com/flap-box/flap/-/raw/master/system/img_build/userpatches/overlay/install_flap.sh | bash
```

- Log out and in again to use the new environment variables.
- Fill the `/flap/system/flapctl.env` file with the correct backup configuration.
- Restore your backup:

```bash
flapctl restore
```

You should now be up and running !

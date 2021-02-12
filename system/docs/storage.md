# Specifying storage location

---

FLAP can automatically setup you disks. The configuration must be place in the `FLAP_DIR/flap_init_config.yml` file.

If you do not set anything, FLAP will simply store the data on you system disk.

- **Warning 1:** this is only mean for empty disks as it will delete everything.
- **Warning 2:** the code is young and not feature full, you should check it out to understand what it does (See [disks.sh](https://gitlab.com/flap-box/flap/-/blob/master/system/cli/cmd/disks.sh)).

Do not hesitate to submit a merge request to support your disk configuration.

## Example 1 - Single disk

FLAP will format `/dev/sda` and mount it at `FLAP_DATA`.

```yaml
env_vars:
    FLAG_DISK_MODE_SINGLE: true
disks:
    - /dev/sda
```

## Example 2 - Raid array

FLAP will attempt to map disks from the server's USB ports.
FLAP will format the disks and setup a RAID1 array with the mapped disks.
FLAP will mount the RAID array at `FLAP_DATA`.

```yaml
env_vars:
    FLAG_DISK_MODE_RAID1: true
disks_path:
    - /sys/bus/usb/drivers/usb/4-1.1/4-1.1\:1.0/host0/target0\:0\:0/0\:0\:0\:0/block
    - /sys/bus/usb/drivers/usb/4-1.2/4-1.2\:1.0/host1/target1\:0\:0/1\:0\:0\:0/block
```

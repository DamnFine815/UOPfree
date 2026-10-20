# Overlay autostart integration and rollback

UOPfree persists across reboots **only by adding two lines** to the existing jailbreak overlay's `/mnt/ubi_boot/jb_overlay/autostart.sh`:

```sh
#UOPfree
sh /mnt/ubi_boot/UOPfree/start.sh >/tmp/UOPfree.log 2>&1 &
```

No firmware image, native player binary, overlay `brick_monitor`, RU-JB `bdpprog` launcher, or unrelated autostart entry is modified. The `&` means the startup script does not block later overlay work; its log remains in volatile `/tmp`.

## Install safeguards

1. Identify exactly one installer payload on attached `/mnt/sd*` USB mounts and verify the embedded `start.sh` SHA-256 and file size.
2. Require a regular readable/writable `autostart.sh`, non-symlink runtime target, available overlay BusyBox and unambiguous marker/launcher counts.
3. Stage the new runtime and copied autostart in temporary paths on their respective target filesystems, preserving metadata where appropriate.
4. Commit runtime first and then the autostart file using same-filesystem rename, verify resulting hashes/entry counts, sync, and write `INSTALLED`.
5. On a controlled error, attempt rollback from staged backups and mark the operation `FAILED`.

## Recognized upgrade/reinstall

A correct current script and lowercase marker gives `ALREADY_INSTALLED` without reapplying the persistent changes. One known earlier script identity and one known earlier casing (`#UOPFree`) are recognized for `UPGRADED`. Unknown directory contents, edited launch commands or duplicate entries fail closed. The removed, differently named development-era runtime is not migrated automatically.

## Independent uninstaller

The separate removal package requires the correct known runtime hash, no unexpected files under `/mnt/ubi_boot/UOPfree/`, and one exact adjacent UOPfree marker/launch pair. It stages a backup before changing the autostart file. A recognized exact EOF trailer is removed by byte-count truncation so the former prefix can be restored byte-for-byte. If later user commands follow the UOPfree entry, a controlled line-oriented removal retains those later commands, though exact original newline bytes are not claimed.

Only after verifying the edited autostart does it remove the one runtime script and empty directory. A failed directory cleanup yields `FAILED`/partial, not a false success.

## Result files and tray signaling

The USB result files are written and synced before a successful-action tray command is attempted through `cliprog`. No tray signal is requested on a reported failure. A missing/failed `cliprog` call does not retrospectively turn a successful installation/removal into a failure.

The uninstaller deliberately never writes player RAM: **a full reboot is mandatory** to restore stock mode after uninstallation.

See [Installation](../INSTALLATION.md), [Uninstallation](../UNINSTALLATION.md) and [Troubleshooting](../TROUBLESHOOTING.md).

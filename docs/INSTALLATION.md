# Installing UOPfree 1.0.0

[Back to README](../README.md)

**Supported target:** OPPO UDP-203 with the RU-JB 65-0131 jailbreak environment, an operational `jb_overlay` and USB AutoScript support. The runtime will refuse an unexpected player/code/data layout instead of guessing an address.

## Prepare before installing

1. Confirm the installed environment is the **RU-JB** firmware, not merely a similarly numbered official OPPO firmware build. OPPO's Device Setup > Firmware Information menu identifies the firmware number; the jailbreak overlay is an additional requirement.
2. Have a tested way to recover your existing jailbreak overlay. The installer changes `jb_overlay/autostart.sh`, although it does **not** replace the native player, firmware or boot monitor.
3. Stop playback, eject any disc, and disconnect other AutoScript installers.
4. Download the published `UOPfree-1.0.0-install.zip` and verify its SHA-256:

```sh
# macOS
shasum -a 256 UOPfree-1.0.0-install.zip
# Linux
sha256sum UOPfree-1.0.0-install.zip
```

Expected result:

```text
60e8efc29b7a9e723b371d0e30a30e20bf98fee0baee9c1e529fed80253ab3fa
```

## Prepare the USB stick

Extract **only** the installation ZIP directly to the root of a clean, player-readable USB stick (FAT32 is a conventional choice for this AutoScript workflow):

```text
USB_ROOT/
  AutoScript/
    AutoScript.TSS
    UOPfree-install.id
    UOPfree-install.sh
    UOPfree/
      start.sh
  CHECK_READONLY.sh
  SHA256SUMS_RELEASE
```

Do not create an extra parent folder around `AutoScript/`. The installer and uninstaller use different AutoScript launchers; **never mix them on one stick**. There is no configuration file or configuration option.

## Install or reinstall

1. Power the OPPO fully off with no disc playing.
2. Insert the prepared USB stick, then start the player.
3. The AutoScript copies the bootstrap to `/tmp` and executes it. The installer verifies the payload identity, existing overlay/autostart ownership and supported runtime state before staging its changes.
4. After startup, inspect `UOPfree-install-result.txt` on the **USB root**:

| Result | Meaning |
| --- | --- |
| `INSTALLED` | Added UOPfree and its startup entry |
| `UPGRADED` | Safely updated a recognized earlier runtime and/or normalized the marker casing |
| `ALREADY_INSTALLED` | Exactly matching runtime and startup entry already exist; no changes needed |
| `FAILED` | Installation aborted; inspect `UOPfree-install.log` |

5. Remove the USB stick. Perform a **full power cycle** before testing UOP-restricted playback. Merely opening the tray does not prove installation was successful.
6. Verify a familiar UOP-restricted sequence: STOP during a locked intro, MENU on an initial license/notice screen, or NEXT to advance through UOP-blocked introductory cards when a valid destination exists.

The installer requests tray eject only after writing and syncing a successful result. If `cliprog` is unavailable or does not open the tray, the result file remains authoritative.

## What is installed?

A **2,793-byte** script at `/mnt/ubi_boot/UOPfree/start.sh`, SHA-256:

```text
6c9775ad973efc9337a16593b33b267b6145e26b97c3b2e3644e6ea9fdd9bc38
```

An existing `/mnt/ubi_boot/jb_overlay/autostart.sh` receives exactly this adjacent two-line block:

```sh
#UOPfree
sh /mnt/ubi_boot/UOPfree/start.sh >/tmp/UOPfree.log 2>&1 &
```

All unrelated autostart entries are preserved. Known prior `#UOPFree` casing is recognized and can be normalized without duplicating the launcher. Unknown files, modified startup lines or unsupported runtime checks cause an intentional abort rather than a forced overwrite. The older differently named development directory is not automatically migrated.

## Verify on the player

After the power cycle, connect using your normal SSH/Telnet access and run:

```sh
cat /tmp/UOPfree.log
```

Expected successful output includes:

```text
UOPfree_1.0.0 START mode=ONE_SHOT_RAM_ONLY
UOPfree_1.0.0 PID=<current-pid> STOCK_CHECK=OK VALUE_BEFORE=00000000
UOPfree_1.0.0 VALUE_AFTER=01000000
UOPfree_1.0.0 RESULT=PASS RAM_ONLY_FILES_UNCHANGED
```

`RESULT=ALREADY_ENABLED` is also legitimate when the expected mode was already active. The PID varies at every boot.

For the bundled read-only file/launcher integrity checker, copy `CHECK_READONLY.sh` separately from the USB stick to `/tmp` on the OPPO and execute:

```sh
sh /tmp/CHECK_READONLY.sh
```

`UOPFREE_READONLY_CHECK=PASS` verifies the installed files and autostart entry; it is **not** a test of disc playback or a pre-install firmware compatibility check. See [Verification](VERIFICATION.md).

## Troubleshooting

If the result is `FAILED`, missing or ambiguous, do not manually modify UOP RAM addresses, replace `bdpprog` or bypass signature checks. Inspect `UOPfree-install.log` and consult [Troubleshooting](TROUBLESHOOTING.md) and [Uninstallation](UNINSTALLATION.md).

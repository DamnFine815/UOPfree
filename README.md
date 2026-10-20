# UOPfree

**UOPfree** is an independent community modification for **OPPO UDP-203 devices running the RU-JB 65-0131 jailbreak environment with `jb_overlay`**. It bypasses Blu-ray User Operation Prohibitions (UOPs) through a lightweight RAM-only modification, unlocking restricted playback controls such as STOP.

> **Risk:** This is unofficial software. It writes four bytes to a running player process after strict compatibility checks and adds a guarded two-line startup entry to the jailbreak overlay. RAM modification or an unexpected boot environment can cause instability. Have a working recovery route before installation.

## Why use it?

Some Blu-ray intros, studio logos and copyright notices prohibit STOP. With UOPfree active, the maintainer was able to stop tested physical Blu-ray Discs, ISO images and BDMV folders without ejecting a disc to escape the restriction.

| Situation | Ordinary disc-enforced behavior | UOPfree on tested material |
| --- | --- | --- |
| STOP blocked during a Blu-ray intro or notice | STOP can be refused | **STOP works** |
| Eject and reinsert a disc in the same player session | UOP restrictions may apply again | One-shot RAM setting remained active |
| Full player restart | Default UOP state returns | UOPfree applies mode 1 again at startup |
| Short studio clip without another chapter | NEXT may have nowhere to go | **No artificial chapter or NEXT target is created** |

UOPfree changes the player's UOP mask, not a disc's chapters or arbitrary BD-J application logic. It cannot create missing navigation targets or guarantee NEXT/SKIP and other operations on every title. It does not bypass AACS/Cinavia or Blu-ray region coding.

## How it works

- Locates the supported running `bdpprog.1` process and waits for startup to settle.
- Checks the expected player size, memory mappings, and a **12-byte original ARM code signature** without modifying code.
- Reads the existing UOP state and, **only when it is exactly the expected default**, changes a **4-byte RAM value** from `00 00 00 00` to `01 00 00 00`.
- Reads the value back and exits. **No persistent daemon, polling loop, firmware image modification or replacement player executable.**
- Uses only `/mnt/ubi_boot/UOPfree/start.sh` and an exact two-line `jb_overlay/autostart.sh` entry for persistence across reboots.

The RAM state itself is temporary: a full reboot clears the previous state; the startup script enables the intended mode again after installation.

## Requirements and limitations

- **OPPO UDP-203 running RU-JB 65-0131**, a working compatible `jb_overlay` and USB AutoScript support.
- An existing readable/writable regular `/mnt/ubi_boot/jb_overlay/autostart.sh` and functioning overlay BusyBox.
- The expected executable size, live memory mappings, instruction bytes and initial RAM state must match. **A similar firmware version string alone is not a compatibility guarantee.**
- An independent backup or recovery route for the installed jailbreak environment.

The documented live observations cover physical discs, ISO and BDMV playback on the specified setup. Other devices and modified player builds have not been validated by this release. See [Compatibility](docs/COMPATIBILITY.md) and [Test evidence](docs/research/TEST_EVIDENCE.md).

## Downloads

Use the **release assets**, not GitHub's automatically generated **Source code (zip/tar.gz)** snapshots:

- **[`UOPfree-1.0.0-install.zip`](https://github.com/DamnFine815/UOPfree/releases/download/v1.0.0/UOPfree-1.0.0-install.zip)** — USB installer / safe reinstaller or recognized upgrade.
- **[`UOPfree-1.0.0-uninstall.zip`](https://github.com/DamnFine815/UOPfree/releases/download/v1.0.0/UOPfree-1.0.0-uninstall.zip)** — separate USB uninstaller; leaves unrelated startup lines intact.
- **[`SHA256SUMS`](https://github.com/DamnFine815/UOPfree/releases/download/v1.0.0/SHA256SUMS)** — published archive fingerprints.

Never combine the install and uninstall packages' `AutoScript/` directories on one USB stick. For full steps see [Installation](docs/INSTALLATION.md) and [Uninstallation](docs/UNINSTALLATION.md).

## Installation at a glance

1. Stop playback, eject any disc and prepare a clean USB stick readable by the OPPO.
2. Extract **only** `UOPfree-1.0.0-install.zip` to the **USB root** so that `AutoScript/AutoScript.TSS` is directly under the root.
3. Insert the USB stick with the player fully powered off, then power on.
4. Read **`UOPfree-install-result.txt`** on the stick. `INSTALLED`, `UPGRADED` and `ALREADY_INSTALLED` are success states; for failures read `UOPfree-install.log`.
5. Remove the USB stick and perform another full power cycle to activate the new startup entry.
6. Check a representative UOP-restricted sequence after reboot; STOP is the control documented in the live hardware tests.

After a successful install, the tray may open automatically. **Tray movement is only a convenience signal, not proof of success**: always check the result file.

## Uninstallation at a glance

Use the independent `UOPfree-1.0.0-uninstall.zip`, extracted alone to a clean USB root, and power-cycle the player. Check for **`UNINSTALLED`** in `UOPfree-uninstall-result.txt`, remove the USB stick, and **power-cycle again**. Uninstalling a script does **not** immediately undo mode 1 in the running player's RAM; reboot restores the default state.

## Installed footprint

Only one small runtime script is installed:

```text
/mnt/ubi_boot/UOPfree/start.sh
```

The installer adds exactly these two lines to the **existing** `jb_overlay/autostart.sh` (preserving other entries):

```sh
#UOPfree
sh /mnt/ubi_boot/UOPfree/start.sh >/tmp/UOPfree.log 2>&1 &
```

It does not replace `bdpprog.1`, alter player launchers, modify firmware partitions, install a new `brick_monitor`, or edit other mods. The uninstaller removes only this recognized startup entry and known runtime script.

## Status and diagnostics

Experienced SSH/Telnet users can inspect the volatile runtime log:

```sh
cat /tmp/UOPfree.log
```

A successful first RAM application ends with `UOPfree_1.0.0 RESULT=PASS RAM_ONLY_FILES_UNCHANGED`. If mode 1 was already active, `RESULT=ALREADY_ENABLED` is also valid. The install ZIP includes `CHECK_READONLY.sh` for a separate **post-install, read-only** file/launcher integrity check; it does not validate disc playback behavior.

## Documentation

- [Installation](docs/INSTALLATION.md), [Uninstallation](docs/UNINSTALLATION.md), [Compatibility](docs/COMPATIBILITY.md)
- [FAQ](docs/FAQ.md), [Troubleshooting](docs/TROUBLESHOOTING.md), [Verification](docs/VERIFICATION.md)
- [Technical architecture](docs/research/ARCHITECTURE.md), [Research index](docs/research/README.md), [Evidence register](docs/research/EVIDENCE_REGISTER.md)
- [Release engineering](docs/research/RELEASE_ENGINEERING.md), [Source build and provenance](docs/BUILD_AND_PROVENANCE.md)
- [External references](docs/SOURCES.md), [Release notes](docs/RELEASE_NOTES_1.0.0.md)

## Development and independence

The readable shell-side runtime, AutoScript install/uninstall launchers and offline release builder are included in this repository. The published ZIPs can be reproduced byte-for-byte from these source files; see [Build and provenance](docs/BUILD_AND_PROVENANCE.md). UOPfree is independent of OPPO Digital and is not affiliated with or endorsed by the manufacturer. See [License status](LICENSE-STATUS.md).

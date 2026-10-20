# UOPfree 1.0.0 - Release Notes

**Bypass disc-authored Blu-ray User Operation Prohibitions (UOPs)** on **OPPO UDP-203 with RU-JB 65-0131 jailbreak firmware and `jb_overlay`**.

## Highlights

- Lightweight, one-shot **RAM-only UOP bypass** for disc-authored restrictions on playback controls.
- **STOP, MENU and NEXT** are maintainer-confirmed examples where UOP-based restrictions were bypassed: STOP during locked intros, MENU on an opening license/notice screen and NEXT to skip UOP-blocked introductory cards.
- STOP was tested on **physical Blu-ray Discs, ISO images and BDMV folders**. MENU and NEXT are later reported live examples whose media types were not separately documented. NEXT still needs a valid navigation destination, and independent BD-J logic is not altered.
- Checks the player process, executable size, exact memory mappings and an original **12-byte code signature** before the 4-byte RAM write.
- No replacement `bdpprog.1`, firmware image, code modification, resident polling daemon or interference with other startup entries.
- Small UBI footprint: one `start.sh` and a guarded two-line `jb_overlay/autostart.sh` entry.
- Separate USB install/uninstall packages, read-only integrity checker, clear result files and optional success-only tray signal.

## Downloads

- [UOPfree-1.0.0-install.zip](https://github.com/DamnFine815/UOPfree/releases/download/v1.0.0/UOPfree-1.0.0-install.zip) — installer, safe reinstaller and recognized upgrade.
- [UOPfree-1.0.0-uninstall.zip](https://github.com/DamnFine815/UOPfree/releases/download/v1.0.0/UOPfree-1.0.0-uninstall.zip) — independent uninstaller; reboot required to clear the current RAM mode.
- [SHA256SUMS](https://github.com/DamnFine815/UOPfree/releases/download/v1.0.0/SHA256SUMS) — SHA-256 fingerprints for both packages.

Extract **only one** USB ZIP directly to a clean USB root with `AutoScript/` immediately inside the root. Do not combine installer and uninstaller files. See the [README](https://github.com/DamnFine815/UOPfree/blob/v1.0.0/README.md), [Installation](https://github.com/DamnFine815/UOPfree/blob/v1.0.0/docs/INSTALLATION.md) and [Uninstallation](https://github.com/DamnFine815/UOPfree/blob/v1.0.0/docs/UNINSTALLATION.md).

## Compatibility and verification

Strictly targeted at the specified RU-JB UDP-203 player layout; incompatible code/memory mappings cause an abort. UOPfree does not disable AACS/Cinavia, bypass region restrictions or manufacture chapter/playlist navigation.

The maintainer reports successful live operation of the mod. The published USB archives preserve **byte-identical functional members** and passed CRC, manifest, source-parity and reproducible-build checks. These offline checks do not constitute a separate on-device USB acceptance test. See [Verification](https://github.com/DamnFine815/UOPfree/blob/v1.0.0/docs/VERIFICATION.md).

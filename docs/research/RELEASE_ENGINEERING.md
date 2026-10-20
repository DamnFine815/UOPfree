# Release engineering and reproducibility

UOPfree 1.0.0 publishes **two distinct USB AutoScript archives**, one for installation and one for removal. Each package has its own `SHA256SUMS_RELEASE` manifest, while the GitHub Release attaches an outer `SHA256SUMS` for both whole ZIPs.

## Installer archive

| Property | Value |
| --- | --- |
| Release asset | `UOPfree-1.0.0-install.zip` |
| Size | **6,860 bytes** |
| SHA-256 | `60e8efc29b7a9e723b371d0e30a30e20bf98fee0baee9c1e529fed80253ab3fa` |
| ZIP entries | **6** |
| Internal manifest hashes | **5/5** |
| Runtime | `AutoScript/UOPfree/start.sh` (2,793 bytes, exact original script) |
| Checker | `CHECK_READONLY.sh` (optional post-install check) |

The installer validates its USB payload, overlay/autostart ownership, safe upgrade state and staging, then appends only the exact UOPfree block. It does not modify player RAM itself; the newly configured `start.sh` does so at a subsequent player startup.

## Uninstaller archive

| Property | Value |
| --- | --- |
| Release asset | `UOPfree-1.0.0-uninstall.zip` |
| Size | **3,595 bytes** |
| SHA-256 | `30c28aa3410fb32df0953a93fc68f1f8cf50a126b592eaf54ad4c5d534561c4b` |
| ZIP entries | **4** |
| Internal manifest hashes | **3/3** |

The uninstaller has a distinct launcher, ID and script; it only removes known UOPfree files and startup lines. A full reboot is needed to clear the current live player's UOP value.

## Payload and archive integrity

The released shell scripts, AutoScript launchers, identifiers and read-only checker retain the exact functional bytes verified from the supplied working payloads. Archive members preserve their original compressed data, timestamps, CRCs and permissions. The published ZIP and manifest hashes are fixed; no executable or control-flow changes were made during release preparation.

## Repeatable source build and QA

This project has a complete **shell-source-to-release** path; it does not depend on the proprietary native OPPO executable. From the repository root:

```sh
sh mkrelease.sh
python3 -m unittest discover -s tests -v
```

The build uses fixed archive metadata and precisely pinned source bytes. It reproduces both final outer ZIP SHA-256 values exactly; any modified source or packaging detail fails verification rather than silently producing a different 1.0.0 package.

Read-only verifier:

```sh
python3 tools/verify_release.py dist/UOPfree-1.0.0-install.zip dist/UOPfree-1.0.0-uninstall.zip
```

The repository includes the exact installer/uninstaller AutoScript scripts and the manifest text files under `docs/research/`. See [Build and provenance](../BUILD_AND_PROVENANCE.md) and [Verification](../VERIFICATION.md).

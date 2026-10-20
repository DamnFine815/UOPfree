# Release engineering and reproducibility

UOPfree 1.0.0 publishes **two distinct USB AutoScript archives**, one for installation and one for removal. The canonical GitHub README is in the repository; neither USB archive contains `README.md`. Each has its own `SHA256SUMS_RELEASE`, while the GitHub Release attaches a separate outer `SHA256SUMS` for the two whole ZIPs.

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

## Exactly what changed during README removal

| Member | Supplied ZIP | README-free release ZIP |
| --- | --- | --- |
| `README.md` | Present | **Removed** |
| `SHA256SUMS_RELEASE` | Included checksum of README | Same other hashes; removed that one line |
| All other files | Verified source bytes | **Identical bytes and identical compressed data** |

The preserved file entries retain CRCs, exact uncompressed contents, original compressed deflate data, timestamps and UNIX permissions. The regenerated outer archive hashes necessarily differ from the supplied originals. No executable or control-flow changes were made.

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

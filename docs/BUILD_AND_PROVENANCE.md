# Source, builds and release provenance

## Source availability

All scripts that make up the UOPfree USB payload are readable in this repository:

- `src/start.sh` — the exact **2,793-byte** one-shot RAM runtime.
- `installer/install/` — exact USB AutoScript launcher, release ID and installation shell script.
- `installer/uninstall/` — exact independent removal launcher, release ID and removal script.
- `installer/read-only/CHECK_READONLY.sh` — exact optional post-install checker.

Unlike projects whose release includes non-source native patch executables, UOPfree's two distributed USB archives contain **shell and text components only**. This repository therefore includes the complete packaged implementation, without shipping a full OPPO player or firmware dump.

## Reproducible source build

With Python 3 and a POSIX shell:

```sh
sh mkrelease.sh
```

This invokes `tools/build_release.py`, recreates the exact release files in `dist/` using the original entry names, archive timestamps, regular-file permissions, source bytes and ZIP compression settings, regenerates both internal manifests, and verifies the **pinned outer SHA-256 hashes**. `dist/SHA256SUMS` provides the two release fingerprints.

Or run directly:

```sh
python3 tools/build_release.py --output ./dist
python3 tools/verify_release.py ./dist/UOPfree-1.0.0-install.zip ./dist/UOPfree-1.0.0-uninstall.zip
```

The build scripts do **not** execute any UOP code, modify a player, require a firmware image or produce a new firmware binary.

## Published release identities

The two published USB archives preserve the verified functional script bytes and are independently checked against the repository source:

```text
60e8efc29b7a9e723b371d0e30a30e20bf98fee0baee9c1e529fed80253ab3fa  UOPfree-1.0.0-install.zip
30c28aa3410fb32df0953a93fc68f1f8cf50a126b592eaf54ad4c5d534561c4b  UOPfree-1.0.0-uninstall.zip
```

A ZIP with the same display name but a different checksum is not this verified artifact.

## Source-to-release parity

`tools/verify_release.py` checks every USB member against its exact repository source file, validates the manifest, package layout, CRC, safe paths, MTKAT/CRLF launchers, IDs, runtime size and pinned SHA-256 values. The original script logic was not normalized or rewritten for GitHub; changing a message in these source files would invalidate their exact release identities until a deliberately new version were built and verified.

## Why the USB ZIP is not the source ZIP

GitHub's automatic **Source code (zip/tar.gz)** packages contain this repository, its documentation and tooling. The bootable files are the separate **Release** attachments; extract only the appropriate release ZIP to the USB root. Never use the source snapshot as an AutoScript installer.

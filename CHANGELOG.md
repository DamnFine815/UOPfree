# Changelog

## 1.0.0 — 2026-10-20

- Released **UOPfree** as a one-shot RAM-only UOP bypass for the supported OPPO UDP-203 RU-JB 65-0131 environment, with maintainer-confirmed examples involving STOP, MENU and NEXT.
- Preserved the live-tested 4-byte RAM method and strict 12-byte original-code / process-layout checks.
- Installed only `/mnt/ubi_boot/UOPfree/start.sh` and the exact `#UOPfree` two-line autostart entry.
- Added separate guarded USB AutoScript installer and uninstaller with result logs and success-only tray request.
- Supported safe reinstallation and one recognized earlier startup-marker/runtime upgrade path.
- Verified the USB archives, manifests and source-file parity with a reproducible release build.
- Added independently reproducible ZIP assembly, exact outer SHA-256 verification and curated technical documentation.

See [Release notes](docs/RELEASE_NOTES_1.0.0.md), [Verification](docs/VERIFICATION.md) and [Test evidence](docs/research/TEST_EVIDENCE.md).

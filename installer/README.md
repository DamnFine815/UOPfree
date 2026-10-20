# UOPfree installer source inventory

`install/` and `uninstall/` contain the **different original AutoScript.TSS launchers**, exact IDs and shell scripts. `read-only/CHECK_READONLY.sh` is an optional separate post-install file/launcher checker.

All these files are copied byte-for-byte from the verified UOPfree 1.0.0 USB packages, including the original CRLF launcher bytes. The standalone release ZIPs are built by `tools/build_release.py`, or simply run `sh mkrelease.sh` from the repository root.

**Do not combine** the two AutoScript trees on the same USB stick. Never replace the runtime/installer scripts from other sources without rebuilding/checking the corresponding package and testing on supported hardware.

See [Installation](../docs/INSTALLATION.md), [Uninstallation](../docs/UNINSTALLATION.md), and [Build and provenance](../docs/BUILD_AND_PROVENANCE.md).

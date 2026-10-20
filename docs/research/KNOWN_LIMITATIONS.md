# Known limitations and design boundaries

1. **One-shot activation.** The runtime exits after checking/writing mode 1. If another component restarts the native player or resets its UOP state later, UOPfree does not monitor or reapply the value automatically. The established clean-boot behavior did not justify a persistent daemon.
2. **Conditional interaction with concurrent patches.** An experimental player-memory modification coincided with a reset to UOP mode 0 when STOP cancelled a disc resume prompt. The cause was not established; a clean boot without that experimental patch behaved normally. This is an observation, not a confirmed generalized UOPfree failure or a resolved bug.
3. **Boot timing.** `jb_overlay` may delay autostart while waiting for network/USB. Extremely early auto-play can theoretically reach a restricted segment before the one-shot script finishes. No intrusive pre-player boot hook was installed.
4. **Navigation does not become universal.** UOP mode 1 does not create new chapters or guarantee NEXT/SKIP, playlist jumps or arbitrary BD-J application behavior.
5. **Strict layout, partial binary identity.** Exact executable size, three map substrings and one original 12-byte code signature provide a narrow compatibility gate, not a cryptographic full-player hash or support for unknown builds.
6. **Uninstall requires restart.** The uninstaller removes files and a two-line startup entry. It does not issue a second RAM write to undo the previous running player's mode 1.
7. **Other overlay content is preserved, not migrated.** Unknown runtime directory contents, arbitrary existing UOPfree launch commands, duplicate markers and symlinks cause failure instead of forced overwrite. A much older different-name development directory is outside automatic migration.
8. **Tray eject is not a result.** Always inspect `UOPfree-*-result.txt` on USB. EJECT can fail independently after a successful operation.
9. **Memory editing is invasive.** Although the change is only four bytes and guarded, kernel/process race conditions and other changes to the shared player can still cause instability. Preserve a recovery route.
10. **No region/DRM/mount feature.** The mod neither changes Blu-ray region coding nor supplies ISO/BDMV support or removes copy protection.

See [Architecture](ARCHITECTURE.md), [Test evidence](TEST_EVIDENCE.md) and [Troubleshooting](../TROUBLESHOOTING.md).

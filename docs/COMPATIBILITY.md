# Compatibility and supported behavior

UOPfree 1.0.0 is intended for **OPPO UDP-203 hardware with RU-JB 65-0131, `jb_overlay` and the matching running `bdpprog.1` layout**. The development test environment included `jb_overlay` v1.7. A firmware number alone is not enough: the runtime checks executable size, process identity, mappings and original code bytes before writing to RAM.

## Tested / reported

| Media or condition | Evidence |
| --- | --- |
| Physical Blu-ray sections that block STOP | STOP unlocked on real hardware |
| Blu-ray ISO playback | STOP behavior confirmed on hardware |
| BDMV folder playback | STOP behavior confirmed on hardware |
| Ejecting and reinserting within one player process | RAM mode 1 remained active |
| Power-cycling the player | Temporary RAM mode reverted; installed startup reapplies it |
| Earlier automated one-shot startup | Successful hardware runtime log and STOP tests |
| Final install/uninstall release workflows | Maintainer reports live testing; detailed historical handoff does not retain every final package log |

The README-free download ZIPs retain every executable member byte-for-byte. Their new outer archive wrappers and manifests were independently validated offline, not re-booted on-device as part of this packaging step.

## Not a universal compatibility promise

- Other hardware, firmware variants, patched `bdpprog.1` images, or differing memory maps have not been verified by this release.
- Some discs enforce controls through title or BD-J logic beyond the internal UOP mask; NEXT/SKIP is not guaranteed.
- A full process restart or another concurrent modification may reset the RAM mode after the one-shot startup script has exited. UOPfree intentionally does not poll continuously.
- An unusual overlay setup may start the script later than desired if network/USB initialization delays `autostart.sh`.

UOPfree does not install ISO/BDMV support, disable copy protection, change Blu-ray region coding or modify the native player executable.

See [Technical architecture](research/ARCHITECTURE.md) and [Test evidence](research/TEST_EVIDENCE.md).

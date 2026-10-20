# Test evidence: UOP mode, playback controls and package behavior

This is a curated list of evidence from the development handoff plus the maintainer's current release report. It distinguishes a real-device behavior observation from a packaging/test-run result and from unsupported generalizations.

| Test condition | Evidence class | Documented outcome |
| --- | --- | --- |
| Native player layout, memory maps and original 12-byte instruction | Hardware inspection | Matched the expected size, mappings and code signature |
| UOP RAM before change | Repeated hardware readback | Four bytes `00 00 00 00` |
| One guarded RAM write | Hardware action plus readback | Changed to `01 00 00 00` |
| Physical Blu-ray with STOP initially blocked | Hardware playback | STOP became usable immediately after the RAM change |
| MENU during an opening license/notice screen | Later direct maintainer report of live playback; no separately retained device log | MENU could be opened despite a UOP-based restriction |
| NEXT on introductory notice/title cards | Later direct maintainer report of live playback; no separately retained device log | NEXT skipped material where disc-authored UOP had blocked it; valid next destination required |
| Disc eject/reinsert in one process | Hardware readback and playback | Mode 1 and STOP behavior persisted |
| Full player restart | Hardware observation | Volatile UOP value reverted; startup reapplication required |
| Automated overlay startup | Hardware log | One-shot script emitted `RESULT=PASS RAM_ONLY_FILES_UNCHANGED` |
| Blu-ray ISO playback | Hardware playback | STOP available in tested material |
| BDMV folder playback | Hardware playback | STOP available in tested material |
| Final named installation/removal operation | Maintainer confirmation | Reported live tested; not every final branch log preserved in the written handoff |
| Installed script / installer / uninstaller byte identity | Offline source/ZIP comparison | Exact retained payload member bytes match supplied archives |
| Release ZIPs and internal manifests | Fresh offline verification | CRC PASS; installer 5/5 and uninstaller 3/3 file hashes |
| Fully independent release build from source | Fresh offline verification | Both outer SHA-256 values reproduced exactly |

## Important negative / conditional result

During **concurrent experimental player-memory patching** and disc resume cancellation, the UOP mode was once observed returning to 0. A clean startup without the other patch did not reproduce the behavior. Whether it was a process reset, direct state reset or some other interaction was not proven. No polling daemon workaround was added to 1.0.0.

## What the evidence does not say

- It does not establish compatibility with every Blu-ray title, pressing or BD-J application.
- NEXT can skip UOP-locked material as observed, but cannot advance where the disc provides no next chapter or other navigation target. MENU can likewise be constrained by rules unrelated to UOP.
- The mode mapping and addresses are based on one supported firmware environment, not an official universal API.
- A successful CRC/hash/source rebuild does not replace USB boot or playback testing on physical hardware.
- The published archive identities and functional payload bytes were verified offline. This does not constitute an additional physical USB-boot test of the final release archives.

Future reports should identify the blocked control (STOP, MENU, NEXT, etc.), disc/source, firmware environment, UOP value, runtime result, player-start timing and whether another mod was active. The newer MENU/NEXT confirmations do not independently establish every disc/media-type combination. See [Evidence register](EVIDENCE_REGISTER.md) and [Known limitations](KNOWN_LIMITATIONS.md).

# Test evidence: UOP mode, STOP and package behavior

This is a curated list of evidence from the development handoff plus the maintainer's current release report. It distinguishes a real-device behavior observation from a packaging/test-run result and from unsupported generalizations.

| Test condition | Evidence class | Documented outcome |
| --- | --- | --- |
| Native player layout, memory maps and original 12-byte instruction | Hardware inspection | Matched the expected size, mappings and code signature |
| UOP RAM before change | Repeated hardware readback | Four bytes `00 00 00 00` |
| One guarded RAM write | Hardware action plus readback | Changed to `01 00 00 00` |
| Physical Blu-ray with STOP initially blocked | Hardware playback | STOP became usable immediately after the RAM change |
| Disc eject/reinsert in one process | Hardware readback and playback | Mode 1 and STOP behavior persisted |
| Full player restart | Hardware observation | Volatile UOP value reverted; startup reapplication required |
| Automated overlay startup | Hardware log | One-shot script emitted `RESULT=PASS RAM_ONLY_FILES_UNCHANGED` |
| Blu-ray ISO playback | Hardware playback | STOP available in tested material |
| BDMV folder playback | Hardware playback | STOP available in tested material |
| Final named installation/removal operation | Maintainer confirmation | Reported live tested; not every final branch log preserved in the written handoff |
| Installed script / installer / uninstaller byte identity | Offline source/ZIP comparison | Exact retained payload member bytes match supplied archives |
| README-free ZIPs and internal manifests | Fresh offline verification | CRC PASS; installer 5/5 and uninstaller 3/3 file hashes |
| Fully independent release build from source | Fresh offline verification | Both outer SHA-256 values reproduced exactly |

## Important negative / conditional result

During **concurrent experimental player-memory patching** and disc resume cancellation, the UOP mode was once observed returning to 0. A clean startup without the other patch did not reproduce the behavior. Whether it was a process reset, direct state reset or some other interaction was not proven. No polling daemon workaround was added to 1.0.0.

## What the evidence does not say

- It does not establish compatibility with every Blu-ray title, pressing or BD-J application.
- It does not promise NEXT/SKIP when a clip lacks an alternate chapter or playlist navigation.
- The mode mapping and addresses are based on one supported firmware environment, not an official universal API.
- A successful CRC/hash/source rebuild does not replace USB boot or playback testing on physical hardware.
- Removing README changes the outer ZIP bytes and SHA-256 identity. Although all functional files are identical, no additional physical USB-boot test was performed *as part of this packaging operation*.

Future reports should state the exact disc/source, firmware environment, before/after UOP value, runtime result, timing of player startup and whether any simultaneous mod was active. See [Evidence register](EVIDENCE_REGISTER.md) and [Known limitations](KNOWN_LIMITATIONS.md).

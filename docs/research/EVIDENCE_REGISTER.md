# Engineering evidence register

| Claim | Evidence type | Basis and qualification |
| --- | --- | --- |
| STOP was locked by UOP in a tested Blu-ray sequence | Hardware observation | [Test evidence](TEST_EVIDENCE.md): a concrete before/after user action |
| Internal mode 0/1 is represented at a four-byte RAM address | Hardware process readback | [UOP mechanism](MEMORY_AND_UOP.md): exactly supported firmware, not universal API |
| Original executable size/maps/ARM instruction signature were checked | Read-only hardware inspection | [UOP mechanism](MEMORY_AND_UOP.md) |
| One RAM write changed 0 to 1 and unlocked STOP | Hardware operation and readback | [Development history](DEVELOPMENT_HISTORY.md), [Test evidence](TEST_EVIDENCE.md) |
| Eject/reinsert preserved mode during the same player process | Hardware observation | [Test evidence](TEST_EVIDENCE.md) |
| Reboot reset volatile mode | Hardware observation | [Test evidence](TEST_EVIDENCE.md) |
| Automated one-shot startup succeeded | Hardware runtime log | [Architecture](ARCHITECTURE.md), [Test evidence](TEST_EVIDENCE.md) |
| STOP worked for tested physical disc, ISO and BDMV playback | Hardware playback | [Test evidence](TEST_EVIDENCE.md); no universal guarantee |
| MENU could be opened on an initial license/notice screen | Later direct maintainer confirmation | [Test evidence](TEST_EVIDENCE.md); no separate device log or media-type record |
| NEXT skipped UOP-blocked introductory cards | Later direct maintainer confirmation | [Test evidence](TEST_EVIDENCE.md); assumes an authored next destination, no separate device log |
| Final installer/uninstaller functionality | Maintainer report | [Test evidence](TEST_EVIDENCE.md); not all final branch logs retained |
| Concurrent experimental patch once coincided with mode reset | Conditional hardware observation | [Known limitations](KNOWN_LIMITATIONS.md); cause not proven |
| Published USB archives preserve functional payload bytes | Exact archive comparison | [Release engineering](RELEASE_ENGINEERING.md) |
| New USB release ZIPs have valid CRC and internal manifests | Fresh offline test | [Verification](../VERIFICATION.md) |
| Both ZIPs reproducible from source at the same SHA-256 | Fresh deterministic source build | [Build and provenance](../BUILD_AND_PROVENANCE.md) |

**Scope:** computer-side integrity checks cannot establish the behavior of every Blu-ray pressing; final release ZIP packaging is not independently re-tested on the OPPO by the packaging script. External OPPO references are background, not certification of private firmware variables. See [Sources](../SOURCES.md).

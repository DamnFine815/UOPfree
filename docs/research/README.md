# UOPfree technical research

These documents explain the on-device observations and design choices behind the one-shot UOP modification. They are curated technical references for public readers, **not a transcript or a catalog of internal experimental builds**.

## Research map

- [Architecture](ARCHITECTURE.md) — boot chain, process checks, RAM state and scope of file changes.
- [UOP mode and memory evidence](MEMORY_AND_UOP.md) — what the four bytes mean in this supported player and what was actually read back.
- [Development history](DEVELOPMENT_HISTORY.md) — failed command approach, first working RAM test, automated startup and packaging decisions.
- [Boot integration](BOOT_INTEGRATION.md) — installation/rollback and protection of unrelated `autostart.sh` lines.
- [Test evidence](TEST_EVIDENCE.md) — live results, maintainer reports and packaging-only tests separated.
- [Known limitations](KNOWN_LIMITATIONS.md) — one-shot lifecycle, reset interaction, startup timing and non-goals.
- [Release engineering](RELEASE_ENGINEERING.md) — archive contents, exact sizes/hashes, reproducible builds and preserved source bytes.
- [Evidence register](EVIDENCE_REGISTER.md) — claim-by-claim evidence classification.

## Evidence categories

- **Hardware observation:** a direct player process readback, log or playback result on the supported UDP-203, as recorded in the development handoff.
- **Maintainer report:** functional status or acceptance confirmed by the maintainer without a complete new archived log for each condition.
- **Offline verification:** source/code identity, ZIP CRC, SHA manifests, shell syntax and reproducible package generation on a separate computer.
- **Inference or limitation:** a plausible model or unresolved condition, not independently proven on all discs/hardware.

The original complete development handoff and its internal notes are retained separately outside the public repository. Technical standards and manufacturer materials are linked from [Sources](../SOURCES.md), without suggesting those sources independently certify UOPfree.

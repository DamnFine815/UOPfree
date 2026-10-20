# Development history: from observation to UOPfree 1.0.0

This report summarizes the project's important findings and decisions without internal chat numbering, deprecated package names or speculative performance claims. Refer to [Evidence register](EVIDENCE_REGISTER.md) for how observations were classified.

## 1. Avoid replacing the native player

The project began with a simple user requirement: **STOP should work during otherwise locked Blu-ray intros and notices**. Editing the native `bdpprog.1` file or storing another ~19.4 MB player binary would introduce unacceptable compatibility and recovery risk. The chosen scope was a tiny, reversible RAM-only operation combined with one overlay startup entry.

## 2. Native command-line attempt did not establish success

An early attempt sent an internal-looking `uopmask` request through the player's CLI. Although the command interface opened, it returned an ioctl failure and no visible STOP improvement. This was correctly rejected: **sending a command is not proof that the player accepted it**.

## 3. Verify the actual process and memory layout

Read-only checks then established the real player process, executable mapping, anonymous writable data region, code signature and current UOP mode. They distinguished the large native player from the two small launchers that share a similar name. The original instruction bytes at `0x001527A0` were verified before any write.

## 4. First successful RAM change

The guarded four-byte RAM operation changed the observed UOP mode from 0 to 1. STOP immediately became usable in a previously locked sequence. The mode persisted across physical disc ejection and reinsertion in the same process, then reset normally after a player restart. This established the **one-shot volatile design**.

## 5. Reliable automatic startup

A small shell script reproduced the RAM operation during normal jailbreak-overlay startup: find the exact player, wait for initialization, check file size/mappings/instruction bytes, verify the expected starting value, write four data bytes, read back and exit. A live log recorded a successful `RESULT=PASS`; physical discs, ISO playback and BDMV folders were subsequently tested for STOP behavior.

## 6. Isolate concurrent-mod interference

In one experiment involving another active player-memory modification, cancelling a disc resume prompt with STOP correlated with the UOP state returning to 0. The issue was not reproduced after a clean startup without that experimental modification. It was therefore **not proven to be a general UOPfree defect**. The project intentionally did not replace its proven one-shot design with permanent polling merely to mask this unresolved condition.

## 7. Final product and USB packaging

The public product name became **UOPfree**, installed at `/mnt/ubi_boot/UOPfree/start.sh` and launched from an exact lowercase `#UOPfree` marker. A prior known marker casing can be normalized safely without duplicate startup lines. The runtime's executable logic, memory address, checks, bytes and control flow were preserved while descriptions and log labels were given final product wording.

Separate guarded installation/removal AutoScripts stage backups, verify known hashes, refuse unknown files, emit USB results and request tray eject only on success. The maintainer reports final mod operation live-tested. For the GitHub release, the redundant README was removed from each USB archive; **all functional ZIP member bytes remain unchanged**, and the exact new archive identities were verified offline.

## 8. Non-goals retained

UOPfree does not create chapters, force NEXT/SKIP when no target exists, rewrite `bdpprog.1`, patch the system firmware, install ISO/BDMV support, modify other mods, implement an early boot process hook, or run a permanent watchdog.

See [Architecture](ARCHITECTURE.md), [Test evidence](TEST_EVIDENCE.md), [Release engineering](RELEASE_ENGINEERING.md), and [Known limitations](KNOWN_LIMITATIONS.md).

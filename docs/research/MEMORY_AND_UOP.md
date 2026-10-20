# User Operation Prohibition (UOP) mode and RAM evidence

## Practical purpose

On some Blu-ray intros, studio logos and legal notices, disc-authored UOP restrictions can disable normal player controls such as **STOP**. On the supported OPPO UDP-203 player, inspection identified an internal `uopmask` mode which can be selected directly in RAM.

This behavior mapping is an observation of the supported native player, **not an official, general-purpose OPPO programming API**:

| 32-bit little-endian RAM value | Observed/internal meaning | UOPfree |
| --- | --- | --- |
| `00 00 00 00` | Disc-default mask: obey UOP restrictions | Expected input |
| `01 00 00 00` | UOP mask disabled / restrictions relaxed | **Desired mode** |
| `02 00 00 00` | Restrict all operations (not used) | Never written |
| Anything else | Unknown state | Abort without writing |

## Address and compatibility record

| Field | Required on this specific player build |
| --- | --- |
| Executable | `/usr/local/bin/bdpprog.1` |
| Exact observed executable size | `19,400,116` bytes |
| Original 12-byte code signature address | `0x001527A0` (read-only) |
| Expected signature bytes | `35 f2 86 e7 cb f0 06 fe 00 97 02 21` |
| Data address | `0x01281638` (four bytes) |
| Code mapping prefix | `00008000-011d8000 r-xp` |
| Anonymous data mapping prefix | `0127f000-01b0f000 rwxp` |
| Backing player mapping suffix | `/mnt/rootfs_normal/usr/local/bin/bdpprog.1` |

The data value lies inside an anonymous read-write-execute area, and the signature lies inside the native player's executable text area. The runtime uses **word-aligned** `dd bs=4` addressing for both reads and the single data write.

## Development observation sequence

- Multiple **read-only** checks before the first change returned `00 00 00 00`, including during a STOP-locked Blu-ray.
- The original 12-byte instruction signature matched exactly.
- A guarded four-byte write changed the readback to `01 00 00 00`.
- Immediately afterward, the user could press STOP in the previously locked sequence.
- Eject/reinsert in the same player session preserved `01 00 00 00` and STOP functionality.
- A full player restart cleared the volatile mode, which justified a one-shot startup application instead of a persistent firmware modification.

This provides strong, local evidence for **the tested behavior**, not universal compatibility with every authoring style or firmware.

## Optional read-only diagnostics

For experienced users on a known compatible device, the following commands **only read** the current value and original code bytes:

```sh
P=$(ps -ef | awk '$NF=="/usr/local/bin/bdpprog.1" {print $2; exit}')
echo "PLAYER_PID=$P"
# UOP data read (four bytes)
dd if="/proc/$P/mem" bs=4 skip=$((0x01281638 / 4)) count=1 2>/dev/null | hexdump -C
# Original player code signature read (12 bytes)
dd if="/proc/$P/mem" bs=4 skip=$((0x001527A0 / 4)) count=3 2>/dev/null | hexdump -C
```

Do not use these addresses as a manual write recipe on unknown builds. A readback demonstrates a state value, not a proof that a particular title will implement its navigation or STOP behavior solely through UOP.

## Why only one write?

The first successful boot-autostart tests showed that mode 1 persisted across disc changes while the same player process remained alive. A continuous watchdog would increase concurrent memory writes and modify the proven design without resolving any documented clean-boot problem. See [Known limitations](KNOWN_LIMITATIONS.md).

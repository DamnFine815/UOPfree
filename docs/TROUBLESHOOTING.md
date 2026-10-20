# Troubleshooting UOPfree 1.0.0

The safest diagnostic approach is **read-only first**. Never bypass the executable signature or force a RAM write on an unknown build just to obtain `PASS`.

## 1. Distinguish USB installation from runtime activation

| Where to look | What it means |
| --- | --- |
| `USB_ROOT/UOPfree-install-result.txt` | `INSTALLED`, `UPGRADED`, `ALREADY_INSTALLED` or `FAILED` |
| `USB_ROOT/UOPfree-install.log` | Bootstrap checks, installer details and tray request warnings |
| `USB_ROOT/UOPfree-uninstall-result.txt` | `UNINSTALLED` or `FAILED` |
| `USB_ROOT/UOPfree-uninstall.log` | Removal details and error messages |
| `/tmp/UOPfree.log` on the player | One-shot runtime activation; look for `RESULT=PASS` or `ABORT reason=...` |

The USB installer writes the startup configuration. It does **not** itself apply the UOP RAM value; the running player process is modified after the next full startup.

## 2. ZIP is not recognized / result file absent

- Verify that `AutoScript/AutoScript.TSS` is directly under the **USB root**, not inside an extra directory.
- Use **only one** install/uninstall package and disconnect other AutoScript media.
- Verify the target firmware and a functioning overlay; check that `jb_overlay/autostart.sh` exists.
- Compare the downloaded ZIP against the published checksum in [Verification](VERIFICATION.md).
- If multiple devices have a matching `UOPfree-install.id`/`UOPfree-uninstall.id`, the scripts refuse ambiguous source media.

## 3. Installer says FAILED

The installer refuses to overwrite a symlink, an unknown `UOPfree` runtime, an unexpected existing autostart entry or duplicated marker/launcher pairs. It also checks the exact embedded `start.sh` SHA-256 and stages changes before committing them.

Typical error text explains the problem: `payload SHA-256 mismatch`, `ambiguous autostart markers/commands`, `unknown file in UOPfree directory`, `regular jb_overlay/autostart.sh missing`, or `overlay BusyBox not executable`. Preserve logs, inspect the existing files and do not delete other components merely to force an install.

An `ALREADY_INSTALLED` result is **successful** and does not imply the startup RAM script has executed in the current boot.

## 4. Runtime says ABORT

Once the player boots with UOPfree installed, inspect:

```sh
cat /tmp/UOPfree.log
```

| Error or result | Interpretation |
| --- | --- |
| `MISSING_TOOL_*` | Needed shell utility unavailable |
| `PLAYER_NOT_FOUND` / `PLAYER_CHANGED` | Expected player process was not ready or changed |
| `PLAYER_SIZE_MISMATCH` | Unexpected `bdpprog.1` executable size |
| `CODE_MAP_MISMATCH` / `PLAYER_MAP_MISMATCH` / `DATA_MAP_MISMATCH` | Supported virtual memory layout was not found |
| `NO_RAM_ACCESS` | Cannot read/write the expected process memory |
| `STOCK_CODE_SIGNATURE_MISMATCH` | Original player-code instruction bytes differ; **do not override** |
| `UNEXPECTED_UOP_VALUE` / `UOP_VALUE_CHANGED` | UOP state not the expected default/unchanged value |
| `RAM_WRITE_FAILED` / `RAM_READBACK_MISMATCH` | Write failed or verification did not match; stop testing and restart normally |
| `RESULT=ALREADY_ENABLED` | Mode 1 was already active; no RAM write was needed |
| `RESULT=PASS RAM_ONLY_FILES_UNCHANGED` | Expected RAM value was applied and read back |

A successful readback confirms the internal RAM value; it is **not** universal certification of behavior on all discs.

## 5. The runtime passes, but an operation remains restricted

UOPfree changes the internal UOP mask; discs or BD-J applications may impose separate navigation rules. A short clip may have no next chapter, so NEXT/SKIP cannot be guaranteed. Check a known UOP-restricted sequence and whether another runtime modification has reset the UOP state. The intentionally one-shot design does not monitor it thereafter.

There was a conditional reset reported during a concurrent experimental patch/resume-cancellation scenario; that has not been established as a defect of UOPfree in a clean supported startup. See [Known limitations](research/KNOWN_LIMITATIONS.md).

## 6. Uninstaller refuses to remove files

The uninstaller checks the installed runtime SHA, the absence of extra files in `/mnt/ubi_boot/UOPfree`, and exactly one recognized autostart entry. It will intentionally refuse an unknown or customized state. If the result is `FAILED`, inspect the log and preserve the overlay for manual review; **do not** replace `bdpprog`, `brick_monitor` or unrelated mod files.

Even after successful `UNINSTALLED`, the existing player process can retain UOP mode 1 until **the next full power cycle**.

## 7. Why did the tray not open?

Both AutoScripts request a tray signal only after a successful result file and `sync`. `cliprog` may be missing or decline the command. Treat the result file as the source of truth, not the tray position.

For help requests, share the error text and **redacted** logs, without firmware images, memory dumps, keys, or device-identifying values.

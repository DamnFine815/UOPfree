# Uninstalling UOPfree 1.0.0

[Back to README](../README.md)

Uninstallation removes **only UOPfree's recognized startup block and installed runtime file**. It does not directly change the UOP state of a player process that is already running. **A full reboot is required to return to the player's normal RAM mode.**

## Before removal

1. Stop playback and eject any disc.
2. Download the **separate** `UOPfree-1.0.0-uninstall.zip` and verify the outer SHA-256:

```text
30c28aa3410fb32df0953a93fc68f1f8cf50a126b592eaf54ad4c5d534561c4b
```

3. Extract it **alone** to the root of a clean USB stick:

```text
USB_ROOT/
  AutoScript/
    AutoScript.TSS
    UOPfree-uninstall.id
    UOPfree-uninstall.sh
  SHA256SUMS_RELEASE
```

Do not combine installation and uninstallation `AutoScript/` folders.

## Remove

1. Fully power off the OPPO, insert the removal USB and start the player.
2. Inspect `UOPfree-uninstall-result.txt` on the USB stick. Only **`UNINSTALLED`** confirms complete removal. If `FAILED`, consult `UOPfree-uninstall.log` before taking further action.
3. Remove the USB stick and **fully power-cycle the OPPO**. The reboot clears any mode-1 UOP state left in the previous `bdpprog.1` process.
4. Test a familiar UOP-restricted section if you want to confirm that the player's normal disc-authored restrictions have returned.

Tray ejection is requested only after a successful result is written and synced. It is not a substitute for checking the result file.

## Exact removal scope

The uninstaller requires a known `UOPfree/start.sh` SHA-256 and exactly one adjacent recognized marker/launcher pair, with either the current `#UOPfree` marker or the known older `#UOPFree` spelling:

```sh
#UOPfree
sh /mnt/ubi_boot/UOPfree/start.sh >/tmp/UOPfree.log 2>&1 &
```

It removes the two lines and `/mnt/ubi_boot/UOPfree/start.sh`, then removes that directory if empty. It refuses to delete unknown files or a customized/duplicated autostart entry. Native OPPO binaries, player launchers, the overlay boot monitor and other mods are not touched.

When the block is still the exact trailer appended at installation, the previous `autostart.sh` prefix is reconstructed **byte-for-byte**, including its prior newline layout. If other lines were appended later, only the recognized two-line block is removed with a line-oriented fallback, preserving later commands; exact original newline bytes are not promised in that edited layout.

## If removal is interrupted

The script stages a backup of `autostart.sh`, validates the recognized block and uses atomic same-filesystem replacement. It reports partial runtime cleanup as `FAILED`, not `UNINSTALLED`. Avoid repeated USB runs without examining the log or manually deleting other mods. See [Troubleshooting](TROUBLESHOOTING.md).

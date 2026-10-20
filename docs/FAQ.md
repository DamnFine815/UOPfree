# Frequently asked questions

**What does UOPfree do?**  It enables the player's UOP-free RAM mode to bypass applicable disc-authored User Operation Prohibitions. Unlocking STOP in restricted Blu-ray sequences is a confirmed example, not the entire purpose of the modification.

**Does this automatically skip every logo or advertisement?**  No. It changes the internal UOP mask; it does not create a missing NEXT chapter, change a BD-J navigation handler, or jump to a new playlist.

**Does it work with ISO and BDMV?**  UOPfree changes the running player's UOP mode. The maintainer confirmed STOP as a tested example on physical discs, ISO images and BDMV folders. UOPfree does not supply ISO/BDMV mounting or other virtual-media infrastructure.

**Does it modify firmware or replace `bdpprog.1`?**  No. The one-shot runtime writes a four-byte data value in the compatible live process and exits. Installation separately appends two lines to the existing `jb_overlay/autostart.sh`.

**Does it run continuously?**  No. It waits for the player at boot, validates the environment, sets the mode once, reads it back and exits.

**Will it affect other mods?**  It does not intentionally edit other mods or their startup lines. As with any modification to a shared running process, concurrent memory changes can interact; combinations are not all comprehensively tested.

**Is there a configuration file?**  No. UOPfree 1.0.0 has no user settings or permanent daemon.

**Why is a reboot needed after installation?**  The installer creates the startup entry. A full power cycle executes it as part of the usual overlay startup path.

**Why do UOP restrictions not return immediately after uninstall?**  The uninstaller does not write running player memory. A full reboot clears the previously changed volatile UOP state.

**Does opening the disc tray mean success?**  No. The USB `*-result.txt` is authoritative; tray eject is only an optional success indication.

**Can I install by downloading GitHub's Source code ZIP?**  No. Use the separate installation and uninstallation assets on the tagged GitHub Release.

See [Installation](INSTALLATION.md), [Uninstallation](UNINSTALLATION.md) and [Troubleshooting](TROUBLESHOOTING.md).

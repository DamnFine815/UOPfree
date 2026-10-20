# Frequently asked questions

**What does UOPfree do?**  It bypasses Blu-ray User Operation Prohibitions (UOPs) using a lightweight RAM-only change. The maintainer confirmed STOP during restricted playback, MENU from an opening license/notice screen and NEXT past UOP-blocked introductory cards.

**Can NEXT skip studio logos, copyright notices or introductory cards?**  **Yes, when UOP is what blocks NEXT and the disc provides a valid navigation target.** This has been confirmed by the maintainer. UOPfree cannot invent a missing chapter, bypass independent BD-J navigation logic or guarantee skipping every screen.

**Can MENU be opened during an initial license or warning screen?**  The maintainer confirmed that MENU could be used on a screen where a UOP restriction would normally prevent it. Separate BD-J behavior may vary by title.

**Does it work with ISO and BDMV?**  UOPfree changes the running player's UOP mode. STOP was confirmed with physical discs, ISO images and BDMV folders; the newer MENU/NEXT examples were not separately classified by media type. UOPfree does not supply ISO/BDMV mounting or other virtual-media infrastructure.

**Does it modify firmware or replace `bdpprog.1`?**  No. The one-shot runtime writes a four-byte data value in the compatible live process and exits. Installation separately appends two lines to the existing `jb_overlay/autostart.sh`.

**Does it run continuously?**  No. It waits for the player at boot, validates the environment, sets the mode once, reads it back and exits.

**Will it affect other mods?**  It does not intentionally edit other mods or their startup lines. As with any modification to a shared running process, concurrent memory changes can interact; combinations are not all comprehensively tested.

**Is there a configuration file?**  No. UOPfree 1.0.0 has no user settings or permanent daemon.

**Why is a reboot needed after installation?**  The installer creates the startup entry. A full power cycle executes it as part of the usual overlay startup path.

**Why do UOP restrictions not return immediately after uninstall?**  The uninstaller does not write running player memory. A full reboot clears the previously changed volatile UOP state.

**Does opening the disc tray mean success?**  No. The USB `*-result.txt` is authoritative; tray eject is only an optional success indication.

**Can I install by downloading GitHub's Source code ZIP?**  No. Use the separate installation and uninstallation assets on the tagged GitHub Release.

See [Installation](INSTALLATION.md), [Uninstallation](UNINSTALLATION.md) and [Troubleshooting](TROUBLESHOOTING.md).

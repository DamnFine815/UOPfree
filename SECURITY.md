# Security and responsible reporting

UOPfree writes four data bytes through `/proc/PID/mem` after checking a strict, firmware-specific runtime layout. Unknown firmware, competing memory changes, an unexpected overlay or kernel differences can still cause player instability. Do not bypass signature or state checks to force an install; keep a verified backup/recovery path.

Report security-sensitive issues to the repository maintainer without publishing credentials, private logs, player firmware images, key material, NAND/flash dumps, unique device identifiers or exploit details. Redact PID-specific and device-specific information as appropriate.

Installation changes the existing jailbreak overlay's `autostart.sh` by a constrained two-line append. Uninstallation removes that exact block and requires a reboot to clear the old player process' RAM state. The project offers no guarantee for untested firmware/hardware variants.

# UOPfree 1.0.0 verification and integrity

## Functional and packaging evidence

The maintainer reports UOPfree's current operation tested live on the supported OPPO UDP-203 environment. The development record specifically includes a confirmed one-shot UOP RAM change and successful STOP on physical discs, ISO and BDMV. It also records real runtime startup and disc reinsertion/reboot behavior. It does not retain a separate complete hardware log for every branch of the final USB installation and removal scripts; see [Test evidence](research/TEST_EVIDENCE.md).

The published USB archives retain **byte-identical functional files**, including the same uncompressed and compressed bytes, CRCs, timestamps and permissions as the supplied working payloads. Both archive envelopes and their manifests passed fresh offline checks; this package verification did not include a separate USB power-on test.

## Published release SHA-256

```text
60e8efc29b7a9e723b371d0e30a30e20bf98fee0baee9c1e529fed80253ab3fa  UOPfree-1.0.0-install.zip
30c28aa3410fb32df0953a93fc68f1f8cf50a126b592eaf54ad4c5d534561c4b  UOPfree-1.0.0-uninstall.zip
```

The install package has **6 ZIP members** with **5/5** checksums in `SHA256SUMS_RELEASE`; the uninstall package has **4 ZIP members** with **3/3**. Both pass ZIP CRC and path/symlink checks.

## Immutable installed runtime

```text
AutoScript/UOPfree/start.sh
size: 2793 bytes
sha256: 6c9775ad973efc9337a16593b33b267b6145e26b97c3b2e3644e6ea9fdd9bc38
```

The runtime's process lookup, size/map/code checks, 4-byte read/write, readback and one-shot exit logic have **not** changed. Both AutoScript launchers, install/uninstall scripts, IDs and read-only checker are likewise preserved exactly. The two `AutoScript.TSS` scripts retain their original CRLF line endings and MTKAT startup commands.

## Verify release assets on a computer

```sh
# From the repository root, with the downloaded GitHub Release ZIPs available:
python3 tools/verify_release.py /path/to/UOPfree-1.0.0-install.zip /path/to/UOPfree-1.0.0-uninstall.zip

# Unit tests
python3 -m unittest discover -s tests -v

# Independently rebuild the same release archives from included source
sh mkrelease.sh
```

Expected markers: `OFFLINE_VERIFICATION=PASS` and `SOURCE_BUILD=PASS`. The independent source builder reproduces both exact ZIP SHA-256 values and writes `dist/SHA256SUMS`.

## Optional read-only inspection on the player

After installation and full power cycle, examine the runtime log:

```sh
cat /tmp/UOPfree.log
```

To check installed script/hash and launcher block, separately copy the installer ZIP's `CHECK_READONLY.sh` to `/tmp` on the OPPO and run:

```sh
sh /tmp/CHECK_READONLY.sh
```

`UOPFREE_READONLY_CHECK=PASS` checks file and autostart integrity; it does **not** certify successful playback-control behavior, verify the firmware compatibility of an uninstalled device, or guarantee that no later memory reset occurred. The original checker includes one historical diagnostic string in a failure branch; it has intentionally been left byte-identical to the supplied live-tested payload.

## Limits of verification

An exact ZIP hash confirms artifact identity, not general hardware compatibility. Firmware-specific process memory writes cannot be proven safe on every modified player. The test coverage and known concurrent-mod interaction are summarized in [Test evidence](research/TEST_EVIDENCE.md) and [Known limitations](research/KNOWN_LIMITATIONS.md).

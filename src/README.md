# UOPfree runtime source

`start.sh` is copied **byte-for-byte** from the verified UOPfree 1.0.0 installation ZIP:

```text
size    2,793 bytes
SHA-256 6c9775ad973efc9337a16593b33b267b6145e26b97c3b2e3644e6ea9fdd9bc38
```

It is a one-shot shell script which checks the supported running OPPO player, reads the original code signature and UOP state, applies mode 1 in RAM once if needed, reads it back, and exits. Do not change RAM offsets, wait logic or error branches to fix problems observed under an unverified firmware.

Changing this file breaks the fixed ZIP SHA-256 identities; create and test a new release candidate rather than silently repackaging 1.0.0. See [Technical design](../docs/research/ARCHITECTURE.md) and [Build and provenance](../docs/BUILD_AND_PROVENANCE.md).

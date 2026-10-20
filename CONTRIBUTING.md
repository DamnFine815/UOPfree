# Contributing

Bug reports and original technical evidence are welcome. Please include the relevant supported firmware environment, whether the source was a physical disc, ISO or BDMV, whether UOPfree had already started, the affected disc operation(s), observed behavior and **redacted** `UOPfree-install.log`, `UOPfree-uninstall.log` or `/tmp/UOPfree.log` excerpts.

Distinguish on-device observations, offline simulation, reproduced source builds and hypotheses. Avoid attaching commercial media, original firmware, protected keys, private user data, process memory dumps or unrelated mod binaries.

Changes to `src/start.sh`, boot entry handling or install/uninstall rollback must be treated as a **new release candidate**: the 1.0.0 ZIP hashes pin exact immutable source files. Run the source rebuild, negative offline tests and fresh hardware installation/UOP-restricted playback/uninstall regression checks before publishing a changed payload.

See [License status](LICENSE-STATUS.md) and [Verification](docs/VERIFICATION.md).

# Sources and external references

These independent sources document **OPPO UDP-203 hardware, normal playback controls and firmware information**. They do **not** document or endorse the UOPfree RAM address, the private `uopmask` mode mapping or the mod's hardware test outcomes: those are from the project's own firmware observations and development record.

1. **OPPO Digital — UDP-203 Support and Firmware Information.** https://www.oppodigital.com/blu-ray-udp-203/blu-ray-udp-203-Support.aspx  
   Official manufacturer firmware/support information and the Device Setup firmware-information menu. RU-JB 65-0131 is a **modified jailbreak environment**, not solely the official firmware version string.
2. **OPPO Digital — UDP-203 User Manual (English).** https://download.oppodigital.com/UDP203/UDP-203_USER_MANUAL_ENGLISH_V1.1.pdf  
   Original operation of the remote STOP and disc playback/navigation controls, auto-play and resume behavior. It is not a specification for UOPfree.

## First-party technical evidence

- [Technical architecture](research/ARCHITECTURE.md) — supported runtime, memory/write boundaries and boot integration.
- [UOP mechanism](research/MEMORY_AND_UOP.md) — observed mode values, signature and before/after RAM checks.
- [Test evidence](research/TEST_EVIDENCE.md) — categories of real-device observation and limits.
- [Evidence register](research/EVIDENCE_REGISTER.md) — source type and qualification for each major claim.
- [Release verification](VERIFICATION.md) — exact downloadable ZIP identities and offline tests.

OPPO Digital trademarks remain the property of their owners. Neither the manufacturer nor external technical references certify this modification. External source links checked October 2026.

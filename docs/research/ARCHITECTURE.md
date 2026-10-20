# UOPfree 1.0.0 architecture

## System boundaries

UOPfree targets an existing **OPPO UDP-203 RU-JB 65-0131** environment with the normal `jb_overlay` stack. It does not install a new firmware image or replace any of the different `bdpprog` launchers/player executables.

Relevant player-side layers (observed in the supported configuration):

```text
/usr/local/bin/bdpprog          (small RU-JB launcher)
  -> /mnt/ubi_boot/bdpprog     (overlay launcher)
    -> /mnt/ubi_boot/jb_overlay/etc/init.sh
      -> jb_overlay/autostart.sh
        -> sh /mnt/ubi_boot/UOPfree/start.sh >/tmp/UOPfree.log 2>&1 &
      -> /usr/local/bin/bdpprog.1   (native player executable)
```

The exact ordering of asynchronous startup work is environment-dependent. `start.sh` waits for the player process itself and then for an additional initialization interval.

## One-shot runtime state machine

1. Validate required shell tools and wait up to **120 seconds** for the precise `/usr/local/bin/bdpprog.1` process, using the `ps` command field rather than a fixed PID.
2. Wait **2 seconds** for startup, and recheck that the PID is still current.
3. Verify the expected on-device executable size (**19,400,116 bytes**) and exact code/data mapping strings in `/proc/PID/maps`.
4. Require read/write access to `/proc/PID/mem`. Read, but do not modify, the original 12-byte ARM signature at `0x001527A0`.
5. Read four bytes at `0x01281638`. Exit cleanly if already `01 00 00 00`; continue only if `00 00 00 00`. Any other value aborts.
6. Recheck PID and prior state, write `01 00 00 00` **once**, then read back and confirm the value.
7. Exit. No installed resident monitor or automatic re-arm is provided.

The script is a shell-side orchestration of existing native player state. It does not install a code hook, modify ARM instructions, patch firmware partitions, or rewrite the native player file.

## Installed footprint

```text
/mnt/ubi_boot/UOPfree/start.sh       2,793 bytes, one regular file
/mnt/ubi_boot/jb_overlay/autostart.sh  exact two-line UOPfree entry added
/tmp/UOPfree.log                     temporary runtime log
```

The startup entry is:

```sh
#UOPfree
sh /mnt/ubi_boot/UOPfree/start.sh >/tmp/UOPfree.log 2>&1 &
```

The installer performs the persistent file changes; the runtime script performs the volatile RAM write on a subsequent boot. Other `autostart.sh` commands are preserved.

## Restoration model

RAM state reverts with player restart. The uninstaller removes the recognized startup command and script, but **does not write a second value to the already running player's RAM**. The user must fully power-cycle to restore native UOP behavior.

## Safety bounds

Checks are deliberately **firmware-layout-specific**, not generic version detection. They are not a full hash of the 19.4 MB native player. An unexpected process, incompatible instruction bytes, unknown UOP value or invalid file ownership causes an abort. Asynchronous process changes between checks and writes cannot be categorically excluded. See [UOP mechanism](MEMORY_AND_UOP.md) and [Known limitations](KNOWN_LIMITATIONS.md).

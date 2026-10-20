#!/bin/sh
# UOPfree 1.0.0 - OPPO UDP-203 USB AutoScript uninstaller.
# Removes ONLY the exact two-line UOPfree autostart block and its known runtime.
VERSION=1.0.0
EXPECTED_SHA=6c9775ad973efc9337a16593b33b267b6145e26b97c3b2e3644e6ea9fdd9bc38
PREVIOUS_SHA=6aafbdb948ca9c04b5afdf15c5cd797de148d196ee505db37585fdba3bac0772
S=""
AMB=0
for ID in /mnt/sd*/AutoScript/UOPfree-uninstall.id; do
    [ -f "$ID" ] || continue
    [ "$(cat "$ID" 2>/dev/null)" = "$VERSION" ] || continue
    CAND="${ID%/UOPfree-uninstall.id}"
    [ -f "$CAND/UOPfree-uninstall.sh" ] || continue
    if [ -z "$S" ]; then S="$CAND"; elif [ "$S" != "$CAND" ]; then AMB=1; fi
done
[ -n "$S" ] || { echo 'UOPfree: matching USB uninstall package not found' >/tmp/UOPfree-uninstall-error.txt; exit 1; }
USBROOT="${S%/*}"
LOG="$USBROOT/UOPfree-uninstall.log"
RESULT="$USBROOT/UOPfree-uninstall-result.txt"
BOOT_GUARD="/tmp/UOPfree-uninstaller-${VERSION}.ran"
[ ! -e "$BOOT_GUARD" ] || exit 0
: > "$BOOT_GUARD" 2>/dev/null || :
exec >>"$LOG" 2>&1
U=/mnt/ubi_boot
D="$U/UOPfree"
OVERLAY="$U/jb_overlay"
AUTO="$OVERLAY/autostart.sh"
BB="$OVERLAY/bin/busybox"
[ -x "$BB" ] || BB=/bin/busybox
MARKER='#UOPfree'
LEGACY_MARKER='#UOPFree'
LAUNCH='sh /mnt/ubi_boot/UOPfree/start.sh >/tmp/UOPfree.log 2>&1 &'
AUTO_NEW="$OVERLAY/.autostart.UOPfree.uninstall.new.$$"
AUTO_BAK="$OVERLAY/.autostart.UOPfree.uninstall.prior.$$"
AUTO_RESTORE="$OVERLAY/.autostart.UOPfree.uninstall.restore.$$"
TRAILER="$OVERLAY/.autostart.UOPfree.trailer.$$"
KEEP_BACKUP=NO
cleanup(){
    rm -f "$AUTO_NEW" "$AUTO_RESTORE" "$TRAILER" 2>/dev/null || :
    [ "$KEEP_BACKUP" = YES ] || rm -f "$AUTO_BAK" 2>/dev/null || :
}
trap cleanup 0
hash(){ "$BB" sha256sum "$1" 2>/dev/null | "$BB" awk '{print $1}'; }
write_result(){
    { echo "UOPfree $VERSION - $1"; echo "$2"; echo 'Details: UOPfree-uninstall.log'; } > "$RESULT"
    "$BB" sync 2>/dev/null || sync
}
fail(){ echo "UNINSTALL=ABORTED: $*"; write_result FAILED "$*"; exit 1; }
eject_success(){
    C=""
    for X in /usr/local/bin/cliprog /usr/bin/cliprog /bin/cliprog; do
        [ -x "$X" ] && { C="$X"; break; }
    done
    if [ -z "$C" ]; then
        echo 'EJECT_WARNING=CLIPROG_NOT_FOUND'
        return 1
    fi
    echo 'EJECT_SIGNAL=drv.ir.rx.sq 0xaf000'
    if printf 'drv.ir.rx.sq 0xaf000\nquit\n' | "$C" >/dev/null 2>&1; then
        echo 'EJECT_REQUEST=SENT'
        return 0
    fi
    echo 'EJECT_WARNING=CLIPROG_COMMAND_FAILED'
    return 1
}
counts(){
    "$BB" awk -v m="$MARKER" -v old="$LEGACY_MARKER" -v c="$LAUNCH" '
        $0==m {mc++}
        $0==old {oc++}
        $0==c {lc++}
        {if (prev==m && $0==c) pc++;
         if (prev==old && $0==c) opc++;
         prev=$0}
        END {printf "%d %d %d %d %d\n", mc,oc,lc,pc,opc}
    ' "$AUTO"
}

echo "=== UOPfree $VERSION UNINSTALL $(date) ==="
[ "$AMB" = 0 ] || fail 'multiple matching USB uninstall packages detected'
[ -d "$OVERLAY" ] && [ -d "$U" ] || fail 'jb_overlay/UBI not available'
[ -x "$BB" ] || fail 'overlay BusyBox unavailable'
[ -f "$AUTO" ] && [ ! -L "$AUTO" ] || fail 'regular jb_overlay/autostart.sh missing'
[ -r "$AUTO" ] && [ -w "$AUTO" ] || fail 'autostart not readable/writable'
[ -d "$D" ] && [ ! -L "$D" ] || fail 'UOPfree runtime directory missing/linked'
[ -f "$D/start.sh" ] && [ ! -L "$D/start.sh" ] || fail 'UOPfree start.sh missing/linked'
INSTALLED_SHA=$(hash "$D/start.sh")
case "$INSTALLED_SHA" in
    "$EXPECTED_SHA"|"$PREVIOUS_SHA") ;;
    *) fail 'UOPfree runtime checksum is unknown; refusing to delete it' ;;
esac
# Safeguard: do not delete unknown content that another mod might have placed in UOPfree.
for ENTRY in "$D"/* "$D"/.[!.]* "$D"/..?*; do
    [ -e "$ENTRY" ] || [ -L "$ENTRY" ] || continue
    [ "$ENTRY" = "$D/start.sh" ] || fail "unexpected additional file in runtime: $ENTRY"
done
STATE=$(counts)
case "$STATE" in
    '1 0 1 1 0') ACTIVE_MARKER="$MARKER" ;;
    '0 1 1 0 1') ACTIVE_MARKER="$LEGACY_MARKER" ;;
    *) fail "expected one recognized two-line UOPfree entry, got ($STATE)" ;;
esac
[ ! -e "$AUTO_NEW" ] && [ ! -e "$AUTO_BAK" ] || fail 'temporary path collision'
cp -p "$AUTO" "$AUTO_BAK" || fail 'cannot back up autostart.sh'
cp -p "$AUTO" "$AUTO_NEW" || fail 'cannot stage autostart with original permissions' 

# If our exact appended trailer is still at EOF, remove it by byte count.
# This recovers autostart.sh byte-for-byte, including any original newline style.
# If the user added other commands after the UOPfree entry, remove only the
# adjacent two lines with awk and retain all later commands instead.
printf '\n%s\n%s\n' "$ACTIVE_MARKER" "$LAUNCH" > "$TRAILER" || fail 'cannot stage exact trailer'
TAIL_SIZE=$("$BB" wc -c < "$TRAILER" | "$BB" awk '{print $1}')
AUTO_SIZE=$("$BB" wc -c < "$AUTO" | "$BB" awk '{print $1}')
if [ "$AUTO_SIZE" -ge "$TAIL_SIZE" ] &&
   "$BB" tail -c "$TAIL_SIZE" "$AUTO" | "$BB" cmp -s - "$TRAILER"; then
    KEEP_BYTES=$((AUTO_SIZE - TAIL_SIZE))
    "$BB" head -c "$KEEP_BYTES" "$AUTO" > "$AUTO_NEW" || fail 'cannot truncate exact autostart trailer'
    echo 'AUTOSTART_RESTORE_MODE=BYTE_IDENTICAL_PREFIX'
else
    if ! "$BB" awk -v m="$ACTIVE_MARKER" -v c="$LAUNCH" '
        $0==m {
            if (getline second <= 0 || second != c) exit 41
            removed++
            next
        }
        { print }
        END { if (removed != 1) exit 42 }
    ' "$AUTO" > "$AUTO_NEW"; then
        fail 'could not stage exact two-line autostart removal'
    fi
    echo 'AUTOSTART_RESTORE_MODE=PRESERVE_LATER_EDITS'
fi
mv -f "$AUTO_NEW" "$AUTO" || fail 'could not update autostart'
if [ "$(counts)" != '0 0 0 0 0' ]; then
    if cp -p "$AUTO_BAK" "$AUTO_RESTORE" && mv -f "$AUTO_RESTORE" "$AUTO"; then
        fail 'autostart verification failed; previous file restored'
    fi
    KEEP_BACKUP=YES
    fail "autostart verification failed; backup retained at $AUTO_BAK"
fi

# Stop future autostart first. The current process RAM state is cleared
# only by a full player reboot; uninstaller never writes /proc/PID/mem.
if ! rm -f "$D/start.sh" || ! rmdir "$D"; then
    echo 'UNINSTALL=PARTIAL: autostart entry removed but runtime directory cleanup failed'
    write_result FAILED 'Autostart entry removed. Runtime directory could not be fully removed. Inspect before retry.'
    exit 1
fi
"$BB" sync 2>/dev/null || sync
echo 'UNINSTALL=COMPLETE'
echo 'OTHER_AUTOSTART_LINES=RETAINED'
echo 'NATIVE_BDPPROG_FILES=UNCHANGED'
echo 'NEXT_ACTION=REMOVE_USB_AND_FULL_REBOOT'
write_result UNINSTALLED 'Only UOPfree autostart entry and /mnt/ubi_boot/UOPfree were removed. Full reboot clears previous RAM setting.'
"$BB" sleep 1 2>/dev/null || sleep 1
eject_success || :
"$BB" sync 2>/dev/null || sync
exit 0

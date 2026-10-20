#!/bin/sh
# UOPfree 1.0.0 - OPPO UDP-203 RU65 USB AutoScript installer.
# Installs the validated one-shot RAM UOP bypass with English status logs.
# Never patches firmware, boot wrappers, player binaries, or running memory.
VERSION=1.0.0
EXPECTED_SHA=6c9775ad973efc9337a16593b33b267b6145e26b97c3b2e3644e6ea9fdd9bc38
PREVIOUS_SHA=6aafbdb948ca9c04b5afdf15c5cd797de148d196ee505db37585fdba3bac0772
EXPECTED_SIZE=2793
S=""
AMB=0
for ID in /mnt/sd*/AutoScript/UOPfree-install.id; do
    [ -f "$ID" ] || continue
    [ "$(cat "$ID" 2>/dev/null)" = "$VERSION" ] || continue
    CAND="${ID%/UOPfree-install.id}"
    [ -f "$CAND/UOPfree-install.sh" ] || continue
    [ -f "$CAND/UOPfree/start.sh" ] || continue
    if [ -z "$S" ]; then S="$CAND"; elif [ "$S" != "$CAND" ]; then AMB=1; fi
done
[ -n "$S" ] || { echo 'UOPfree: matching USB payload not found' >/tmp/UOPfree-install-error.txt; exit 1; }
USBROOT="${S%/*}"
LOG="$USBROOT/UOPfree-install.log"
RESULT="$USBROOT/UOPfree-install-result.txt"
BOOT_GUARD="/tmp/UOPfree-installer-${VERSION}.ran"
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
PAYLOAD="$S/UOPfree/start.sh"
STAGE="$U/.UOPfree.new.$$"
AUTO_NEW="$OVERLAY/.autostart.UOPfree.new.$$"
AUTO_BAK="$OVERLAY/.autostart.UOPfree.prior.$$"
AUTO_RESTORE="$OVERLAY/.autostart.UOPfree.restore.$$"
UPGRADE_NEW="$U/.UOPfree.upgrade.new.$$"
UPGRADE_BAK="$U/.UOPfree.upgrade.prior.$$"
UPGRADE_RESTORE="$U/.UOPfree.upgrade.restore.$$"
UPGRADE_COMMITTED=NO
KEEP_UPGRADE_BACKUP=NO
RT_COMMITTED=NO
AUTO_COMMITTED=NO
KEEP_BACKUP=NO
cleanup(){
    [ ! -f "$STAGE/start.sh" ] || rm -f "$STAGE/start.sh" 2>/dev/null || :
    [ ! -d "$STAGE" ] || rmdir "$STAGE" 2>/dev/null || :
    rm -f "$AUTO_NEW" "$AUTO_RESTORE" "$TRAILER" "$UPGRADE_NEW" "$UPGRADE_RESTORE" 2>/dev/null || :
    [ "$KEEP_BACKUP" = YES ] || rm -f "$AUTO_BAK" 2>/dev/null || :
    [ "$KEEP_UPGRADE_BACKUP" = YES ] || rm -f "$UPGRADE_BAK" 2>/dev/null || :
}
trap cleanup 0
hash(){ "$BB" sha256sum "$1" 2>/dev/null | "$BB" awk '{print $1}'; }
write_result(){
    { echo "UOPfree $VERSION - $1"; echo "$2"; echo 'Details: UOPfree-install.log'; } > "$RESULT"
    "$BB" sync 2>/dev/null || sync
}
fail(){
    echo "FAILED: $*"
    if [ "$UPGRADE_COMMITTED" = YES ]; then
        if cp -p "$UPGRADE_BAK" "$UPGRADE_RESTORE" && mv -f "$UPGRADE_RESTORE" "$D/start.sh"; then
            echo 'ROLLBACK_PREVIOUS_RUNTIME=RESTORED'
        else
            KEEP_UPGRADE_BACKUP=YES
            echo "ROLLBACK_PREVIOUS_RUNTIME=FAILED; saved copy at $UPGRADE_BAK"
        fi
    fi
    if [ "$AUTO_COMMITTED" = YES ]; then
        if cp -p "$AUTO_BAK" "$AUTO_RESTORE" && mv -f "$AUTO_RESTORE" "$AUTO"; then
            echo 'ROLLBACK_AUTOSTART=RESTORED'
        else
            KEEP_BACKUP=YES
            echo "ROLLBACK_AUTOSTART=FAILED; saved original at $AUTO_BAK"
        fi
    fi
    if [ "$RT_COMMITTED" = YES ]; then
        if [ -f "$D/start.sh" ]; then rm -f "$D/start.sh" 2>/dev/null || :; fi
        rmdir "$D" 2>/dev/null || echo 'ROLLBACK_RUNTIME=FAILED; inspect UOPfree directory'
    fi
    write_result FAILED "$*"
    exit 1
}
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
    ' "${1:-$AUTO}"
}

echo "=== UOPfree $VERSION INSTALL $(date) ==="
echo "USB_SOURCE=$S"
[ "$AMB" = 0 ] || fail 'multiple matching USB install packages detected'
[ -d "$U" ] && [ -d "$OVERLAY" ] || fail 'jb_overlay/UBI not available'
[ -x "$BB" ] || fail 'overlay BusyBox not executable'
[ -f "$AUTO" ] && [ ! -L "$AUTO" ] || fail 'regular jb_overlay/autostart.sh missing'
[ -r "$AUTO" ] && [ -w "$AUTO" ] || fail 'jb_overlay/autostart.sh not readable/writable'
[ ! -L "$D" ] || fail 'UOPfree path is a symbolic link'
[ -f "$PAYLOAD" ] && [ ! -L "$PAYLOAD" ] || fail 'USB start.sh missing or linked'
[ "$(hash "$PAYLOAD")" = "$EXPECTED_SHA" ] || fail 'USB payload SHA-256 mismatch'
PAYSIZE=$("$BB" wc -c < "$PAYLOAD" | "$BB" awk '{print $1}')
[ "$PAYSIZE" = "$EXPECTED_SIZE" ] || fail 'USB payload size mismatch'
[ ! -e "$STAGE" ] && [ ! -e "$AUTO_NEW" ] && [ ! -e "$AUTO_BAK" ] || fail 'temporary path collision'

STATE=$(counts) || fail 'cannot inspect autostart.sh'
case "$STATE" in
    '1 0 1 1 0'|'0 1 1 0 1')
        # An installed UOPfree 1.0.0 may have the older marker casing.
        # Rename only that exact marker, never create a duplicate launcher.
        LEGACY=NO
        [ "$STATE" != '0 1 1 0 1' ] || LEGACY=YES
        [ -d "$D" ] && [ ! -L "$D" ] && [ -f "$D/start.sh" ] &&
          [ ! -L "$D/start.sh" ] || fail 'existing UOPfree runtime is missing or linked'
        for ENTRY in "$D"/* "$D"/.[!.]* "$D"/..?*; do
            [ -e "$ENTRY" ] || [ -L "$ENTRY" ] || continue
            [ "$ENTRY" = "$D/start.sh" ] || fail "unknown file in UOPfree directory: $ENTRY"
        done
        CURRENT_SHA=$(hash "$D/start.sh")
        case "$CURRENT_SHA" in
            "$EXPECTED_SHA"|"$PREVIOUS_SHA") ;;
            *) fail 'autostart entry exists but runtime is not a recognized UOPfree release' ;;
        esac
        if [ "$CURRENT_SHA" = "$EXPECTED_SHA" ] && [ "$LEGACY" = NO ]; then
            echo 'INSTALL=ALREADY_INSTALLED'
            write_result ALREADY_INSTALLED 'UOPfree runtime and correctly cased autostart entry already present. No files changed.'
            "$BB" sleep 1 2>/dev/null || sleep 1
            eject_success || :
            "$BB" sync 2>/dev/null || sync
            exit 0
        fi

        # Stage the marker rename with autostart permissions preserved.
        # The already-installed player startup command is identical.
        if [ "$LEGACY" = YES ]; then
            [ ! -e "$AUTO_NEW" ] && [ ! -e "$AUTO_BAK" ] &&
              [ ! -e "$AUTO_RESTORE" ] || fail 'autostart migration staging collision'
            cp -p "$AUTO" "$AUTO_BAK" || fail 'cannot save existing autostart'
            cp -p "$AUTO" "$AUTO_NEW" || fail 'cannot stage existing autostart'
            "$BB" sed 's/^#UOPFree$/#UOPfree/' "$AUTO" > "$AUTO_RESTORE" ||
                fail 'cannot prepare exact marker rename'
            cat "$AUTO_RESTORE" > "$AUTO_NEW" || fail 'cannot stage marker rename'
            [ "$(counts "$AUTO_NEW")" = '1 0 1 1 0' ] || fail 'staged marker rename failed verification'
        fi

        # The older runtime can be upgraded without ever touching native players.
        if [ "$CURRENT_SHA" = "$PREVIOUS_SHA" ]; then
            [ ! -e "$UPGRADE_NEW" ] && [ ! -e "$UPGRADE_BAK" ] &&
              [ ! -e "$UPGRADE_RESTORE" ] || fail 'upgrade temporary path collision'
            cp -p "$D/start.sh" "$UPGRADE_BAK" || fail 'cannot save previous runtime'
            cp "$PAYLOAD" "$UPGRADE_NEW" || fail 'cannot stage English runtime'
            chmod 755 "$UPGRADE_NEW" || fail 'cannot set staged runtime permissions'
            [ "$(hash "$UPGRADE_NEW")" = "$EXPECTED_SHA" ] || fail 'runtime upgrade checksum mismatch'
            [ "$(counts)" = "$STATE" ] || fail 'autostart changed during runtime upgrade staging'
            [ "$(hash "$D/start.sh")" = "$PREVIOUS_SHA" ] || fail 'runtime changed during upgrade staging'
            mv -f "$UPGRADE_NEW" "$D/start.sh" || fail 'cannot activate upgraded runtime'
            UPGRADE_COMMITTED=YES
            [ "$(hash "$D/start.sh")" = "$EXPECTED_SHA" ] || fail 'runtime upgrade verification failed'
        fi
        if [ "$LEGACY" = YES ]; then
            [ "$(counts)" = "$STATE" ] || fail 'autostart changed during marker staging'
            mv -f "$AUTO_NEW" "$AUTO" || fail 'cannot activate corrected autostart marker'
            AUTO_COMMITTED=YES
            [ "$(counts)" = '1 0 1 1 0' ] || fail 'post-update autostart verification failed'
        fi
        "$BB" sync 2>/dev/null || sync
        UPGRADE_COMMITTED=NO
        AUTO_COMMITTED=NO
        echo 'INSTALL=UPGRADED'
        [ "$LEGACY" != YES ] || echo 'AUTOSTART_MARKER=RENAMED_TO_UOPfree'
        [ "$CURRENT_SHA" != "$PREVIOUS_SHA" ] || echo 'RUNTIME=UPDATED_TO_ENGLISH_RELEASE'
        write_result UPGRADED 'Existing UOPfree 1.0.0 updated safely; marker normalized to #UOPfree and runtime updated only if necessary. Reboot to apply.'
        "$BB" sleep 1 2>/dev/null || sleep 1
        eject_success || :
        "$BB" sync 2>/dev/null || sync
        exit 0 ;;
    '0 0 0 0 0') ;;
    *) fail "ambiguous autostart markers/commands (counts=$STATE); refusing changes" ;;
esac
[ ! -e "$D" ] || fail 'existing /mnt/ubi_boot/UOPfree directory; refusing overwrite'

# Stage both changes, preserving the existing autostart file byte-for-byte
# except for the two appended UOPfree lines. Old #UOPFree markers are normalized safely.
mkdir "$STAGE" || fail 'cannot create runtime staging directory'
cp "$PAYLOAD" "$STAGE/start.sh" || fail 'cannot stage start.sh'
chmod 755 "$STAGE/start.sh" || fail 'cannot chmod start.sh'
[ "$(hash "$STAGE/start.sh")" = "$EXPECTED_SHA" ] || fail 'staged start.sh SHA mismatch'
cp -p "$AUTO" "$AUTO_BAK" || fail 'cannot back up original autostart.sh'
cp -p "$AUTO" "$AUTO_NEW" || fail 'cannot stage autostart.sh'
printf '\n%s\n%s\n' "$MARKER" "$LAUNCH" >> "$AUTO_NEW" || fail 'cannot append autostart entry'
[ "$(counts)" = '0 0 0 0 0' ] || fail 'autostart modified concurrently during staging'
[ -s "$AUTO_NEW" ] || fail 'staged autostart empty'

# Commit runtime first, then atomically commit autostart using same-filesystem mv.
mv "$STAGE" "$D" || fail 'cannot activate runtime directory'
RT_COMMITTED=YES
mv -f "$AUTO_NEW" "$AUTO" || fail 'cannot activate autostart entry'
AUTO_COMMITTED=YES
[ "$(hash "$D/start.sh")" = "$EXPECTED_SHA" ] || fail 'post-install runtime SHA mismatch'
[ "$(counts)" = '1 0 1 1 0' ] || fail 'post-install autostart entry verification failed'
"$BB" sync 2>/dev/null || sync
RT_COMMITTED=NO
AUTO_COMMITTED=NO
echo 'INSTALL=COMPLETE'
echo 'NATIVE_BDPPROG_FILES=UNCHANGED'
echo 'REGIONAUTO_PERS_BRICKMONITOR=UNTOUCHED'
echo 'NEXT_ACTION=REMOVE_USB_AND_FULL_REBOOT'
write_result INSTALLED 'UOPfree/start.sh installed and exact two-line autostart entry appended. Remove USB and full reboot.'
"$BB" sleep 1 2>/dev/null || sleep 1
eject_success || :
"$BB" sync 2>/dev/null || sync
exit 0

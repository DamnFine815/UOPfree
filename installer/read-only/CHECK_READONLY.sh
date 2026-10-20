#!/bin/sh
# UOPfree 1.0.0 - checks on OPPO; strictly read-only.
U=/mnt/ubi_boot
AUTO="$U/jb_overlay/autostart.sh"
D="$U/UOPfree"
BB="$U/jb_overlay/bin/busybox"
[ -x "$BB" ] || BB=/bin/busybox
EXPECTED_SHA=6c9775ad973efc9337a16593b33b267b6145e26b97c3b2e3644e6ea9fdd9bc38
MARKER='#UOPfree'
LAUNCH='sh /mnt/ubi_boot/UOPfree/start.sh >/tmp/UOPfree.log 2>&1 &'
OK=YES
bad(){ echo "FAIL: $*"; OK=NO; }
[ -x "$BB" ] || { echo 'FAIL: overlay BusyBox missing'; exit 1; }
[ -f "$AUTO" ] && [ ! -L "$AUTO" ] || bad 'autostart.sh missing or linked'
[ -f "$D/start.sh" ] && [ ! -L "$D/start.sh" ] || bad 'UOPfree/start.sh missing or linked'
if [ -f "$D/start.sh" ]; then
  ACTUAL=$("$BB" sha256sum "$D/start.sh" 2>/dev/null | "$BB" awk '{print $1}')
  [ "$ACTUAL" = "$EXPECTED_SHA" ] && echo 'OK: UOPfree 1.0.0 runtime SHA-256 verified' || bad 'V002 runtime checksum mismatch'
fi
if [ -f "$AUTO" ]; then
  COUNTS=$("$BB" awk -v m="$MARKER" -v c="$LAUNCH" '
    $0==m {mc++} $0==c {lc++} {if(prev==m && $0==c) pc++; prev=$0}
    END {printf "%d %d %d\n",mc,lc,pc}
  ' "$AUTO")
  [ "$COUNTS" = '1 1 1' ] && echo 'OK: one exact UOPfree autostart block' || bad "autostart entry unexpected ($COUNTS)"
fi
printf 'UOPFREE_READONLY_CHECK=%s\n' "$( [ "$OK" = YES ] && echo PASS || echo FAIL )"
[ "$OK" = YES ]

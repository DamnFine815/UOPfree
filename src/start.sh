#!/bin/sh
# UOPfree 1.0.0 - OPPO UDP-203 RU65; one-shot RAM-only UOP bypass.
# Does not modify player files, firmware, boot scripts or other mods.

PATH="${PATH:-/bin:/usr/bin}:/bin:/usr/bin:/usr/local/bin"
export PATH
PLAYER=/usr/local/bin/bdpprog.1
PROC_ROOT=/proc
EXPECTED_SIZE=19400116
CODE_SKIP=$((0x001527A0 / 4))
DATA_SKIP=$((0x01281638 / 4))
EXPECTED_CODE=35f286e7cbf006fe00970221
MAX_WAIT=120

log()  { printf 'UOPfree_1.0.0 %s\n' "$*"; }
fail() { log "ABORT reason=$1"; exit 1; }

for tool in ps awk grep ls dd hexdump sleep; do
    command -v "$tool" >/dev/null 2>&1 || fail "MISSING_TOOL_$tool"
done

# POSIX awk, compatible with the hexdump -C output already tested on OPPO.
read_hex() {
    dd if="$MEM" bs=4 skip="$1" count="$2" 2>/dev/null |
        hexdump -C |
        awk 'NR == 1 {
            for (i = 2; i <= NF; i++)
                if ($i ~ /^[0-9a-fA-F][0-9a-fA-F]$/) printf "%s", $i
            print ""
        }'
}

find_player() {
    ps -ef 2>/dev/null |
        awk -v expected="$PLAYER" '$NF == expected { print $2; exit }'
}

log 'START mode=ONE_SHOT_RAM_ONLY'
i=0
P=
while [ "$i" -lt "$MAX_WAIT" ]; do
    P=$(find_player)
    [ -n "$P" ] && [ -r "$PROC_ROOT/$P/maps" ] && break
    i=$((i + 1))
    sleep 1
done
[ -n "$P" ] && [ -r "$PROC_ROOT/$P/maps" ] || fail PLAYER_NOT_FOUND

# Give the just-started player time to finish its initial setup.
sleep 2
[ "$(find_player)" = "$P" ] || fail PLAYER_CHANGED

SIZE=$(ls -ln "$PLAYER" 2>/dev/null | awk 'NR == 1 { print $5 }')
[ "$SIZE" = "$EXPECTED_SIZE" ] || fail PLAYER_SIZE_MISMATCH

MAPS="$PROC_ROOT/$P/maps"
# Verified on the supported OPPO UDP-203 RU65 executable and BSS layout.
grep -Fq '00008000-011d8000 r-xp' "$MAPS" || fail CODE_MAP_MISMATCH
grep -Fq '/mnt/rootfs_normal/usr/local/bin/bdpprog.1' "$MAPS" || fail PLAYER_MAP_MISMATCH
grep -Fq '0127f000-01b0f000 rwxp' "$MAPS" || fail DATA_MAP_MISMATCH

MEM="$PROC_ROOT/$P/mem"
[ -r "$MEM" ] && [ -w "$MEM" ] || fail NO_RAM_ACCESS

CODE=$(read_hex "$CODE_SKIP" 3)
[ "$CODE" = "$EXPECTED_CODE" ] || fail STOCK_CODE_SIGNATURE_MISMATCH

BEFORE=$(read_hex "$DATA_SKIP" 1)
log "PID=$P STOCK_CHECK=OK VALUE_BEFORE=$BEFORE"
case "$BEFORE" in
    01000000) log 'RESULT=ALREADY_ENABLED'; exit 0 ;;
    00000000) ;;
    *) fail UNEXPECTED_UOP_VALUE ;;
esac

# Recheck PID and data value just before touching the four RAM bytes.
[ "$(find_player)" = "$P" ] || fail PLAYER_CHANGED_BEFORE_WRITE
[ "$(read_hex "$DATA_SKIP" 1)" = '00000000' ] || fail UOP_VALUE_CHANGED

if ! printf '\001\000\000\000' |
    dd of="$MEM" bs=4 seek="$DATA_SKIP" count=1 conv=notrunc 2>&1; then
    fail RAM_WRITE_FAILED
fi
AFTER=$(read_hex "$DATA_SKIP" 1)
log "VALUE_AFTER=$AFTER"
[ "$AFTER" = '01000000' ] || fail RAM_READBACK_MISMATCH
log 'RESULT=PASS RAM_ONLY_FILES_UNCHANGED'
exit 0

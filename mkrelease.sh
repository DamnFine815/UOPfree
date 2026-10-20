#!/bin/sh
# Rebuild the two published UOPfree 1.0.0 archives exactly from source.
# This command does not alter the OPPO, the existing USB ZIPs, or firmware.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
[ "$#" -le 1 ] || { echo 'Usage: sh mkrelease.sh [output-dir]' >&2; exit 2; }
OUT=${1:-"$ROOT/dist"}
python3 "$ROOT/tools/build_release.py" --output "$OUT"
python3 "$ROOT/tools/verify_release.py" "$OUT/UOPfree-1.0.0-install.zip" "$OUT/UOPfree-1.0.0-uninstall.zip"

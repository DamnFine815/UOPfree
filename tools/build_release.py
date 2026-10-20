#!/usr/bin/env python3
"""Recreate exact pinned UOPfree 1.0.0 USB ZIPs from the published source tree.

All runtime/bootstrap/checker source files remain byte-identical. Only the
project's known archive metadata and the regenerated per-ZIP SHA256SUMS_RELEASE
are added. Fails if the resulting archive is not exactly the nominated release.
"""
from __future__ import annotations

import argparse
import hashlib
from pathlib import Path
from zipfile import ZipFile, ZipInfo, ZIP_DEFLATED

from verify_release import BASE, EXPECTED, sha256, verify_one

DATE = (2026, 10, 20, 0, 0, 0)
UNIX_REGULAR_644 = 0o100644 << 16


def emit(out: Path, kind: str) -> Path:
    expected = EXPECTED[kind]
    blobs: dict[str, bytes] = {}
    for member, src in expected['source'].items():
        blobs[member] = (BASE / src).read_bytes()
    manifest = ''.join(
        f'{sha256(blobs[name])}  {name}\n'
        for name in expected['members'] if name != 'SHA256SUMS_RELEASE'
    )
    blobs['SHA256SUMS_RELEASE'] = manifest.encode('ascii')
    filename = f'UOPfree-1.0.0-{kind}.zip'
    path = out / filename
    with ZipFile(path, 'w') as z:
        for member in expected['members']:
            info = ZipInfo(member, DATE)
            info.create_system = 3
            info.external_attr = UNIX_REGULAR_644
            info.compress_type = ZIP_DEFLATED
            z.writestr(info, blobs[member], compress_type=ZIP_DEFLATED, compresslevel=9)
    verify_one(path, kind)
    return path


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--output', type=Path, required=True)
    ns = ap.parse_args()
    ns.output.mkdir(parents=True, exist_ok=True)
    produced = [emit(ns.output, kind) for kind in ('install', 'uninstall')]
    (ns.output / 'SHA256SUMS').write_text(
        ''.join(f'{sha256(p.read_bytes())}  {p.name}\n' for p in produced), encoding='ascii'
    )
    print('SOURCE_BUILD=PASS (reproduced exact release ZIP identities)')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())

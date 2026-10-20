#!/usr/bin/env python3
"""Read-only verification of the two pinned README-free UOPfree 1.0.0 ZIPs.

Checks package identity, archive entries, source parity, internal manifests,
CRCs, safety, AutoScript launchers, and the exact one-shot runtime identity.
Does not execute code on an OPPO or claim a hardware acceptance test.
"""
from __future__ import annotations

import hashlib
import pathlib
import sys
import zipfile

BASE = pathlib.Path(__file__).resolve().parent.parent
EXPECTED = {
    'install': {
        'sha': '60e8efc29b7a9e723b371d0e30a30e20bf98fee0baee9c1e529fed80253ab3fa',
        'members': (
            'AutoScript/AutoScript.TSS',
            'AutoScript/UOPfree/start.sh',
            'AutoScript/UOPfree-install.id',
            'AutoScript/UOPfree-install.sh',
            'CHECK_READONLY.sh',
            'SHA256SUMS_RELEASE',
        ),
        'source': {
            'AutoScript/AutoScript.TSS': 'installer/install/AutoScript.TSS',
            'AutoScript/UOPfree/start.sh': 'src/start.sh',
            'AutoScript/UOPfree-install.id': 'installer/install/UOPfree-install.id',
            'AutoScript/UOPfree-install.sh': 'installer/install/UOPfree-install.sh',
            'CHECK_READONLY.sh': 'installer/read-only/CHECK_READONLY.sh',
        },
    },
    'uninstall': {
        'sha': '30c28aa3410fb32df0953a93fc68f1f8cf50a126b592eaf54ad4c5d534561c4b',
        'members': (
            'AutoScript/AutoScript.TSS',
            'AutoScript/UOPfree-uninstall.id',
            'AutoScript/UOPfree-uninstall.sh',
            'SHA256SUMS_RELEASE',
        ),
        'source': {
            'AutoScript/AutoScript.TSS': 'installer/uninstall/AutoScript.TSS',
            'AutoScript/UOPfree-uninstall.id': 'installer/uninstall/UOPfree-uninstall.id',
            'AutoScript/UOPfree-uninstall.sh': 'installer/uninstall/UOPfree-uninstall.sh',
        },
    },
}
START_SHA = '6c9775ad973efc9337a16593b33b267b6145e26b97c3b2e3644e6ea9fdd9bc38'


def sha256(blob: bytes) -> str:
    return hashlib.sha256(blob).hexdigest()


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def assert_safe_member(name: str) -> None:
    require(bool(name) and not name.startswith('/'), 'absolute/empty ZIP path: ' + name)
    require('\\' not in name, 'backslash ZIP path: ' + name)
    require(all(p not in ('', '.', '..') for p in name.split('/')), 'unsafe ZIP path: ' + name)
    require(not name.startswith('__MACOSX/') and
            not any(p == '.DS_Store' or p.startswith('._') for p in name.split('/')),
            'macOS metadata in ZIP: ' + name)


def parse_manifest(content: bytes, expected_names: set[str]) -> list[tuple[str, str]]:
    try:
        raw_lines = content.decode('ascii').splitlines()
    except UnicodeDecodeError as exc:
        raise ValueError('manifest is not ASCII') from exc
    require(bool(raw_lines), 'empty release manifest')
    names = []
    rows = []
    for line in raw_lines:
        require(len(line) > 66 and line[64:66] == '  ', 'invalid manifest line')
        digest, name = line[:64], line[66:]
        require(len(digest) == 64 and all(c in '0123456789abcdef' for c in digest),
                'invalid manifest digest: ' + name)
        assert_safe_member(name)
        names.append(name)
        rows.append((name, digest))
    require(len(names) == len(set(names)), 'duplicate manifest member')
    require(set(names) == expected_names, 'manifest member set does not match archive')
    return rows


def verify_one(path: pathlib.Path, kind: str, source: pathlib.Path = BASE) -> None:
    expected = EXPECTED[kind]
    require(path.is_file(), 'missing ZIP: ' + str(path))
    require(sha256(path.read_bytes()) == expected['sha'], 'wrong outer ZIP SHA-256: ' + kind)
    with zipfile.ZipFile(path) as z:
        entries = z.infolist()
        members = [i.filename for i in entries]
        require(tuple(members) == expected['members'], 'archive layout/order mismatch: ' + kind)
        require(len(set(members)) == len(members), 'duplicate archive member')
        require('README.md' not in members, 'unexpected README in USB archive')
        require(z.testzip() is None, 'ZIP CRC failure: ' + kind)
        for member in entries:
            assert_safe_member(member.filename)
            require((member.external_attr >> 16) & 0o170000 != 0o120000,
                    'symlink member: ' + member.filename)
        manifest = parse_manifest(z.read('SHA256SUMS_RELEASE'), set(members) - {'SHA256SUMS_RELEASE'})
        for name, digest in manifest:
            require(sha256(z.read(name)) == digest, 'incorrect manifest checksum: ' + name)
        assert len(manifest) == (5 if kind == 'install' else 3)
        tss = z.read('AutoScript/AutoScript.TSS')
        require(tss.startswith(b'#MTKAT'), 'incorrect AutoScript marker')
        require(b'\r\n' in tss and b'\n' not in tss.replace(b'\r\n', b''),
                'incorrect AutoScript line endings')
        require(z.read(f'AutoScript/UOPfree-{kind}.id') == b'1.0.0\n',
                'incorrect AutoScript release ID')
        if kind == 'install':
            require(sha256(z.read('AutoScript/UOPfree/start.sh')) == START_SHA,
                    'one-shot runtime identity mismatch')
            require(len(z.read('AutoScript/UOPfree/start.sh')) == 2793,
                    'unexpected runtime size')
        for member, relpath in expected['source'].items():
            sp = source / relpath
            require(sp.is_file(), 'missing source file: ' + relpath)
            require(sp.read_bytes() == z.read(member), 'source and packaged bytes differ: ' + relpath)
        print(f'  {kind}: SHA256=PASS CRC=PASS paths=PASS ' +
              f'manifest={len(manifest)}/{len(manifest)} source={len(expected["source"])}/{len(expected["source"])}')


def main(argv: list[str] | None = None) -> int:
    args = list(sys.argv[1:] if argv is None else argv)
    if len(args) != 2:
        print('Usage: python3 tools/verify_release.py INSTALL_ZIP UNINSTALL_ZIP', file=sys.stderr)
        return 2
    try:
        verify_one(pathlib.Path(args[0]), 'install')
        verify_one(pathlib.Path(args[1]), 'uninstall')
    except (OSError, ValueError, zipfile.BadZipFile, KeyError, UnicodeError) as exc:
        print('OFFLINE_VERIFICATION=FAIL: ' + str(exc), file=sys.stderr)
        return 1
    print('OFFLINE_VERIFICATION=PASS (not a hardware execution test)')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())

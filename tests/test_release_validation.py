"""Offline checks for UOPfree's release verification and source build."""
from __future__ import annotations

import pathlib
import sys
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))
import verify_release as v


class TestReleaseValidation(unittest.TestCase):
    def test_known_sha256(self):
        self.assertEqual(v.sha256(b'abc'),
                         'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad')

    def test_safe_paths(self):
        for p in ['AutoScript/AutoScript.TSS', 'AutoScript/UOPfree/start.sh', 'CHECK_READONLY.sh']:
            v.assert_safe_member(p)

    def test_unsafe_paths_rejected(self):
        for p in ['', '../bad', '/tmp/bad', 'x/../../bad', 'x//bad', 'x/./bad',
                  'x\\bad', 'x/.DS_Store', '__MACOSX/stuff', 'x/._resource']:
            with self.subTest(p=p), self.assertRaises(ValueError):
                v.assert_safe_member(p)

    def test_manifest_valid(self):
        data = b'\x00test'
        content = (v.sha256(data) + '  AutoScript/AutoScript.TSS\n').encode('ascii')
        self.assertEqual(v.parse_manifest(content, {'AutoScript/AutoScript.TSS'}),
                         [('AutoScript/AutoScript.TSS', v.sha256(data))])

    def test_missing_manifest_path_rejected(self):
        content = (v.sha256(b'a') + '  AutoScript/AutoScript.TSS\n').encode('ascii')
        with self.assertRaisesRegex(ValueError, 'member set'):
            v.parse_manifest(content, {'AutoScript/UOPfree/start.sh'})

    def test_duplicate_manifest_rejected(self):
        line = v.sha256(b'a') + '  AutoScript/AutoScript.TSS\n'
        with self.assertRaisesRegex(ValueError, 'duplicate'):
            v.parse_manifest((line + line).encode('ascii'), {'AutoScript/AutoScript.TSS'})

    def test_malformed_manifest_rejected(self):
        with self.assertRaises(ValueError):
            v.parse_manifest(b'not a manifest\n', {'AutoScript/AutoScript.TSS'})

    def test_release_layout_and_pin_lengths(self):
        self.assertEqual(len(v.EXPECTED['install']['members']), 6)
        self.assertEqual(len(v.EXPECTED['uninstall']['members']), 4)
        self.assertEqual(len(v.START_SHA), 64)
        self.assertEqual(len(v.EXPECTED['install']['sha']), 64)
        self.assertEqual(len(v.EXPECTED['uninstall']['sha']), 64)


if __name__ == '__main__':
    unittest.main()

import 'dart:typed_data';

import 'package:barrel_lock/barrel_lock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BackupBluetoothTransfer', () {
    test('encode and decode round-trip', () {
      final bytes = Uint8List.fromList(
        List<int>.generate(1200, (i) => i % 256),
      );
      final frames = BackupBluetoothTransfer.encodeFrames(
        bytes,
        chunkSize: 512,
      );
      expect(frames.length, 3);

      final restored = BackupBluetoothTransfer.decodeFrames(frames);
      expect(restored, bytes);
    });

    test('rejects missing frames', () {
      final bytes = Uint8List.fromList(
        List<int>.generate(1200, (i) => i % 256),
      );
      final frames = BackupBluetoothTransfer.encodeFrames(
        bytes,
        chunkSize: 512,
      );
      expect(frames.length, greaterThan(1));
      expect(
        () => BackupBluetoothTransfer.decodeFrames([frames.first]),
        throwsA(isA<BackupBluetoothException>()),
      );
    });

    test('session meta json round-trip', () {
      const meta = BackupBluetoothSessionMeta(totalBytes: 99, sha256Hex: 'abc');
      final decoded = BackupBluetoothSessionMeta.decodeJson(
        BackupBluetoothSessionMeta.encodeJson(meta),
      );
      expect(decoded.totalBytes, 99);
      expect(decoded.sha256Hex, 'abc');
    });
  });
}

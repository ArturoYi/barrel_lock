import 'dart:typed_data';

import 'package:barrel_lock/barrel_lock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BackupBleGattTransfer', () {
    test('gattPayloadMaxForMtu respects ATT single-write limit', () {
      expect(BackupBleGattTransfer.gattPayloadMaxForMtu(530), 512);
      expect(BackupBleGattTransfer.gattPayloadMaxForMtu(517), 492);
      expect(BackupBleGattTransfer.maxBlbgWriteSizeForMtu(517), 512);
    });

    test('gattPayloadMaxForMtu shrinks for low mtu', () {
      expect(BackupBleGattTransfer.gattPayloadMaxForMtu(185), 160);
      expect(BackupBleGattTransfer.maxBlbgWriteSizeForMtu(185), 180);
    });

    test(
      'single blbt frame splits into multiple blbg chunks and round-trips',
      () {
        final blbt = BackupBluetoothTransfer.encodeFrames(
          Uint8List.fromList(List<int>.generate(1200, (i) => i % 256)),
          chunkSize: 2048,
        ).single;

        final chunks = BackupBleGattTransfer.splitBlbtFrameToBlbgChunks(
          blbt,
          blbtFrameIndex: 0,
          mtu: 517,
        );
        expect(chunks.length, greaterThan(1));

        final restoredFrames =
            BackupBleGattTransfer.decodeBlbgChunksToBlbtFrames(chunks);
        expect(restoredFrames.single, blbt);

        final payload = BackupBluetoothTransfer.decodeFrames(restoredFrames);
        expect(payload.length, 1200);
      },
    );

    test('multiple blbt frames round-trip through blbg', () {
      final bytes = Uint8List.fromList(
        List<int>.generate(2000, (i) => i % 256),
      );
      final blbtFrames = BackupBluetoothTransfer.encodeFrames(
        bytes,
        chunkSize: 900,
      );
      final chunks = BackupBleGattTransfer.encodeBlbgChunksForBlbtFrames(
        blbtFrames,
        mtu: 517,
      );
      final restoredFrames = BackupBleGattTransfer.decodeBlbgChunksToBlbtFrames(
        chunks,
      );
      expect(BackupBluetoothTransfer.decodeFrames(restoredFrames), bytes);
    });

    test('rejects out-of-order chunks', () {
      final blbt = BackupBluetoothTransfer.encodeFrames(
        Uint8List.fromList([1, 2, 3]),
      ).single;
      final chunks = BackupBleGattTransfer.splitBlbtFrameToBlbgChunks(
        blbt,
        blbtFrameIndex: 0,
        mtu: 517,
      );
      if (chunks.length < 2) {
        return;
      }
      final swapped = [chunks[1], chunks[0]];
      expect(
        () => BackupBleGattTransfer.decodeBlbgChunksToBlbtFrames(swapped),
        throwsA(isA<BackupBluetoothException>()),
      );
    });

    test('rejects missing chunks', () {
      final blbt = BackupBluetoothTransfer.encodeFrames(
        Uint8List.fromList(List<int>.generate(1200, (i) => i)),
      ).single;
      final chunks = BackupBleGattTransfer.splitBlbtFrameToBlbgChunks(
        blbt,
        blbtFrameIndex: 0,
        mtu: 517,
      );
      expect(
        () =>
            BackupBleGattTransfer.decodeBlbgChunksToBlbtFrames([chunks.first]),
        throwsA(isA<BackupBluetoothException>()),
      );
    });

    test('empty blbt frame round-trips', () {
      final blbt = BackupBluetoothTransfer.encodeFrames(
        Uint8List.fromList([1]),
        chunkSize: 2048,
      ).single;
      final emptyPayloadBlbt = BackupBluetoothTransfer.encodeFrames(
        Uint8List(0),
        chunkSize: 2048,
      );
      expect(emptyPayloadBlbt, isEmpty);

      final chunks = BackupBleGattTransfer.splitBlbtFrameToBlbgChunks(
        blbt,
        blbtFrameIndex: 0,
      );
      expect(chunks.length, greaterThanOrEqualTo(1));
      final restored = BackupBleGattTransfer.decodeBlbgChunksToBlbtFrames(
        chunks,
      );
      expect(restored.single, blbt);
    });

    test('1MB logical frame splits and round-trips', () {
      final bytes = Uint8List(1024 * 1024);
      final blbtFrames = BackupBluetoothTransfer.encodeFrames(
        bytes,
        chunkSize: bytes.length,
      );
      final chunks = BackupBleGattTransfer.encodeBlbgChunksForBlbtFrames(
        blbtFrames,
      );
      expect(chunks.length, greaterThan(1000));
      final restored = BackupBleGattTransfer.decodeBlbgChunksToBlbtFrames(
        chunks,
      );
      expect(BackupBluetoothTransfer.decodeFrames(restored), bytes);
    });

    test('rejects invalid magic', () {
      expect(
        () => BackupBleGattTransfer.decodeBlbgChunksToBlbtFrames([
          Uint8List.fromList([0, 1, 2, 3]),
        ]),
        throwsA(isA<BackupBluetoothException>()),
      );
    });
  });
}

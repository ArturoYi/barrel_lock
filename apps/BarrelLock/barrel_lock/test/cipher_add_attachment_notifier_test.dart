import 'dart:typed_data';

import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CipherAddAttachmentNotifier', () {
    test('addPending and removePending manage memory list', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(
        cipherAddAttachmentNotifierProvider.notifier,
      );
      notifier.addPending(
        fileName: 'front.jpg',
        mimeType: 'image/jpeg',
        bytes: Uint8List.fromList([1, 2, 3]),
      );

      var state = container.read(cipherAddAttachmentNotifierProvider);
      expect(state.pending, hasLength(1));
      expect(state.pending.first.fileName, 'front.jpg');

      final localId = state.pending.first.localId;
      notifier.removePending(localId);

      state = container.read(cipherAddAttachmentNotifierProvider);
      expect(state.pending, isEmpty);
    });

    test('clearPending discards all pending attachments', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(
        cipherAddAttachmentNotifierProvider.notifier,
      );
      notifier.addPending(
        fileName: 'front.jpg',
        mimeType: 'image/jpeg',
        bytes: Uint8List.fromList([1]),
      );
      notifier.clearPending();

      final state = container.read(cipherAddAttachmentNotifierProvider);
      expect(state.pending, isEmpty);
    });

    test('rejects unsupported mime type', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(
        cipherAddAttachmentNotifierProvider.notifier,
      );
      notifier.addPending(
        fileName: 'doc.pdf',
        mimeType: 'application/pdf',
        bytes: Uint8List.fromList([1, 2]),
      );

      final state = container.read(cipherAddAttachmentNotifierProvider);
      expect(state.pending, isEmpty);
      expect(state.errorMessage, isNotNull);
    });

    test('rejects sixth pending attachment', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(
        cipherAddAttachmentNotifierProvider.notifier,
      );
      for (var i = 0; i < AttachmentLimits.maxCountPerCipher; i++) {
        notifier.addPending(
          fileName: 'file-$i.jpg',
          mimeType: 'image/jpeg',
          bytes: Uint8List.fromList([i]),
        );
      }

      notifier.addPending(
        fileName: 'extra.jpg',
        mimeType: 'image/jpeg',
        bytes: Uint8List.fromList([99]),
      );

      final state = container.read(cipherAddAttachmentNotifierProvider);
      expect(state.pending, hasLength(AttachmentLimits.maxCountPerCipher));
      expect(state.errorMessage, isNotNull);
    });
  });
}

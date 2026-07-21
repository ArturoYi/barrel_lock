import 'dart:typed_data';

import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late StorageRepositories repos;
  late VaultManageModel vaultManage;
  late CipherAddModel cipherAdd;
  late AttachmentManageModel attachmentManage;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Cryptography.instance = Cryptography.instance.withRandom(
      SecureRandom.forTesting(seed: 33),
    );
    AppCrypto.reset();
    AppCrypto.init(secretKeyBytes: List<int>.filled(32, 9));

    db = AppDatabase.memory();
    repos = StorageRepositories(db);
    vaultManage = VaultManageModel(repos);
    cipherAdd = CipherAddModel(repos, vaultManage);
    attachmentManage = AttachmentManageModel(repos);
  });

  tearDown(() async {
    AppCrypto.reset();
    await db.close();
  });

  Future<String> createIdentityCipher() {
    return cipherAdd.saveIdentityDocumentCipher(
      preferredVaultId: null,
      title: '身份证',
      documentType: '身份证',
      fullName: '张三',
      documentNumber: '110101199001011234',
      issueDate: '2020-01-01',
      expiryDate: '2030-01-01',
      notes: '',
    );
  }

  group('AttachmentManageModel', () {
    test('insertAttachment encrypts file and name', () async {
      final cipherUuid = await createIdentityCipher();
      final bytes = Uint8List.fromList([1, 2, 3, 4]);

      final attachId = await attachmentManage.insertAttachment(
        cipherUuid: cipherUuid,
        fileName: 'front.jpg',
        mimeType: 'image/jpeg',
        bytes: bytes,
      );

      final row = await repos.cipherAttachments.findById(attachId);
      expect(row, isNotNull);
      expect(row!.fileSize, bytes.length);

      final name = await EncryptedNameCodec.decrypt(row.fileName);
      expect(name, 'front.jpg');

      final decrypted = await attachmentManage.loadDecryptedBytes(attachId);
      expect(decrypted, bytes);
    });

    test(
      'watchMetadataByCipher returns metadata without loading file early',
      () async {
        final cipherUuid = await createIdentityCipher();
        await attachmentManage.insertAttachment(
          cipherUuid: cipherUuid,
          fileName: 'front.jpg',
          mimeType: 'image/jpeg',
          bytes: Uint8List.fromList([1, 2, 3]),
        );

        final metadata = await attachmentManage
            .watchMetadataByCipher(cipherUuid)
            .first;
        expect(metadata, hasLength(1));
        expect(metadata.first.fileName, 'front.jpg');
        expect(metadata.first.fileSize, 3);
      },
    );

    test('insertAll persists multiple pending attachments', () async {
      final cipherUuid = await createIdentityCipher();
      await attachmentManage.insertAll(
        cipherUuid: cipherUuid,
        pending: [
          PendingAttachment(
            localId: 'local-1',
            fileName: 'front.jpg',
            mimeType: 'image/jpeg',
            bytes: Uint8List.fromList([1]),
          ),
          PendingAttachment(
            localId: 'local-2',
            fileName: 'back.png',
            mimeType: 'image/png',
            bytes: Uint8List.fromList([2, 3]),
          ),
        ],
      );

      final rows = await repos.cipherAttachments.findByCipher(cipherUuid);
      expect(rows, hasLength(2));
    });

    test('rejects oversized file', () async {
      final cipherUuid = await createIdentityCipher();
      final oversized = Uint8List(AttachmentLimits.maxFileSizeBytes + 1);

      expect(
        () => attachmentManage.insertAttachment(
          cipherUuid: cipherUuid,
          fileName: 'big.jpg',
          mimeType: 'image/jpeg',
          bytes: oversized,
        ),
        throwsA(isA<AttachmentManageException>()),
      );
    });

    test('rejects sixth attachment', () async {
      final cipherUuid = await createIdentityCipher();
      for (var i = 0; i < AttachmentLimits.maxCountPerCipher; i++) {
        await attachmentManage.insertAttachment(
          cipherUuid: cipherUuid,
          fileName: 'file-$i.jpg',
          mimeType: 'image/jpeg',
          bytes: Uint8List.fromList([i]),
        );
      }

      expect(
        () => attachmentManage.insertAttachment(
          cipherUuid: cipherUuid,
          fileName: 'extra.jpg',
          mimeType: 'image/jpeg',
          bytes: Uint8List.fromList([99]),
        ),
        throwsA(isA<AttachmentManageException>()),
      );
    });

    test('deleteAttachment removes row', () async {
      final cipherUuid = await createIdentityCipher();
      final attachId = await attachmentManage.insertAttachment(
        cipherUuid: cipherUuid,
        fileName: 'front.jpg',
        mimeType: 'image/jpeg',
        bytes: Uint8List.fromList([1]),
      );

      await attachmentManage.deleteAttachment(attachId);

      expect(await repos.cipherAttachments.findById(attachId), isNull);
    });

    test('rejects unsupported mime type', () async {
      final cipherUuid = await createIdentityCipher();

      expect(
        () => attachmentManage.insertAttachment(
          cipherUuid: cipherUuid,
          fileName: 'doc.pdf',
          mimeType: 'application/pdf',
          bytes: Uint8List.fromList([1, 2]),
        ),
        throwsA(isA<AttachmentManageException>()),
      );
    });
  });
}

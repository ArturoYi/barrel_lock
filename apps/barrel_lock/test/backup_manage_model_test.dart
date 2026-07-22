import 'dart:io';

import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late StorageRepositories repos;
  late VaultManageModel vaultManage;
  late CipherAddModel cipherAdd;
  late Directory backupRoot;
  late BackupManageModel backupManage;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Cryptography.instance = Cryptography.instance.withRandom(
      SecureRandom.forTesting(seed: 11),
    );
    AppCrypto.reset();
    AppCrypto.init(secretKeyBytes: List<int>.filled(32, 9));

    db = AppDatabase.memory();
    repos = StorageRepositories(db);
    vaultManage = VaultManageModel(repos);
    cipherAdd = CipherAddModel(repos, vaultManage);
    backupRoot = await Directory.systemTemp.createTemp('backup_manage_test');
    backupManage = BackupManageModel(
      repos,
      backupRootOverride: backupRoot,
      maxLocalBackups: 2,
    );
  });

  tearDown(() async {
    AppCrypto.reset();
    await db.close();
    if (await backupRoot.exists()) {
      await backupRoot.delete(recursive: true);
    }
  });

  Future<String> seedCipher() {
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

  group('BackupManageModel', () {
    test('createSnapshotBytes includes cipher rows', () async {
      await seedCipher();

      final bytes = await backupManage.createSnapshotBytes();

      expect(bytes, isNotEmpty);
      expect(await repos.cipherEntries.findAll(), hasLength(1));
    });

    test('createLocalBackup writes file and backup_log row', () async {
      await seedCipher();

      final result = await backupManage.createLocalBackup(note: '测试');
      final file = File(result.filePath);

      expect(await file.exists(), isTrue);
      expect(result.logId, isNotEmpty);

      final logs = await backupManage.watchRecentBackups().first;
      expect(logs, hasLength(1));
      expect(logs.first.note, '测试');
      expect(logs.first.backupPath, result.filePath);
    });

    test('merge restore keeps local-only cipher', () async {
      final localCipher = await seedCipher();
      final bytes = await backupManage.createSnapshotBytes();

      final importedCipher = await cipherAdd.saveIdentityDocumentCipher(
        preferredVaultId: null,
        title: '另一张证',
        documentType: '身份证',
        fullName: '李四',
        documentNumber: '110101199002021234',
        issueDate: '2020-01-01',
        expiryDate: '2030-01-01',
        notes: '',
      );

      await backupManage.restoreFromBytes(bytes, mode: BackupImportMode.merge);

      expect(await repos.cipherEntries.findById(localCipher), isNotNull);
      expect(await repos.cipherEntries.findById(importedCipher), isNotNull);
    });

    test('replace restore removes local-only cipher', () async {
      await seedCipher();
      final bytes = await backupManage.createSnapshotBytes();

      final localOnly = await cipherAdd.saveIdentityDocumentCipher(
        preferredVaultId: null,
        title: '待删除',
        documentType: '身份证',
        fullName: '王五',
        documentNumber: '110101199003031234',
        issueDate: '2020-01-01',
        expiryDate: '2030-01-01',
        notes: '',
      );

      await backupManage.restoreFromBytes(
        bytes,
        mode: BackupImportMode.replace,
      );

      expect(await repos.cipherEntries.findById(localOnly), isNull);
      expect(await repos.cipherEntries.findAll(), hasLength(1));
    });

    test('pruneOldBackups keeps newest entries only', () async {
      await seedCipher();
      await backupManage.createLocalBackup(note: '1');
      await backupManage.createLocalBackup(note: '2');
      await backupManage.createLocalBackup(note: '3');

      final logs = await backupManage.watchRecentBackups().first;
      expect(logs, hasLength(2));
      expect(logs.first.note, '3');
      expect(logs.last.note, '2');
    });
  });
}

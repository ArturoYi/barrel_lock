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
  late ClearDataModel clearData;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Cryptography.instance = Cryptography.instance.withRandom(
      SecureRandom.forTesting(seed: 12),
    );
    AppCrypto.reset();
    AppCrypto.init(secretKeyBytes: List<int>.filled(32, 9));

    db = AppDatabase.memory();
    repos = StorageRepositories(db);
    vaultManage = VaultManageModel(repos);
    cipherAdd = CipherAddModel(repos, vaultManage);
    clearData = ClearDataModel(repos);
  });

  tearDown(() async {
    AppCrypto.reset();
    await db.close();
  });

  Future<void> seedCipher() async {
    await cipherAdd.saveIdentityDocumentCipher(
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

  group('ClearDataModel', () {
    test('wipeAllPasswords removes vaults, folders and ciphers', () async {
      await seedCipher();

      expect(await repos.vaults.findAll(), isNotEmpty);
      expect(await repos.cipherEntries.findAll(), isNotEmpty);

      await clearData.wipeAllPasswords();

      expect(await repos.vaults.findAll(), isEmpty);
      expect(await repos.folders.findAll(), isEmpty);
      expect(await repos.cipherEntries.findAll(), isEmpty);
      expect(await repos.cipherAttachments.findAll(), isEmpty);
    });

    test('wipeAllPasswords leaves backup_log rows intact', () async {
      await seedCipher();
      await repos.backupLogs.insert(
        BackupLog(
          logId: AppIds.newUuid(),
          backupTime: DateTime.now().toUtc(),
          backupPath: '/tmp/test.blbak',
          backupPasswordSalt: Uint8List(16),
          vaultVersion: DatabaseSchemaVersion.current,
          isEncrypted: true,
          createdAt: DateTime.now().toUtc(),
        ),
      );

      await clearData.wipeAllPasswords();

      expect(await repos.backupLogs.findAll(), hasLength(1));
    });
  });
}

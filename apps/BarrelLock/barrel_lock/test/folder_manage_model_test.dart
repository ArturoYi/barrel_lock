import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late StorageRepositories repos;
  late VaultManageModel vaultManage;
  late FolderManageModel folderManage;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Cryptography.instance = Cryptography.instance.withRandom(
      SecureRandom.forTesting(seed: 22),
    );
    AppCrypto.reset();
    AppCrypto.init(secretKeyBytes: List<int>.filled(32, 8));

    db = AppDatabase.memory();
    repos = StorageRepositories(db);
    vaultManage = VaultManageModel(repos);
    folderManage = FolderManageModel(repos);
  });

  tearDown(() async {
    AppCrypto.reset();
    await db.close();
  });

  group('FolderManageModel', () {
    test('createFolder and watchSummariesByVault', () async {
      final vaultId = await vaultManage.createVault(name: '个人库');
      final folderId = await folderManage.createFolder(
        vaultUuid: vaultId,
        name: '社交',
      );

      final summaries = await folderManage.watchSummariesByVault(vaultId).first;
      expect(summaries, hasLength(1));
      expect(summaries.first.id, folderId);
      expect(summaries.first.name, '社交');
    });

    test('empty vault has no folders', () async {
      final vaultId = await vaultManage.createVault(name: '空库');
      final summaries = await folderManage.watchSummariesByVault(vaultId).first;
      expect(summaries, isEmpty);
    });
  });
}

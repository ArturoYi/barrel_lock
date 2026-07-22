import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late StorageRepositories repos;
  late VaultManageModel model;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Cryptography.instance = Cryptography.instance.withRandom(
      SecureRandom.forTesting(seed: 21),
    );
    AppCrypto.reset();
    AppCrypto.init(secretKeyBytes: List<int>.filled(32, 9));

    db = AppDatabase.memory();
    repos = StorageRepositories(db);
    model = VaultManageModel(repos);
  });

  tearDown(() async {
    AppCrypto.reset();
    await db.close();
  });

  group('VaultManageModel', () {
    test('createVault inserts decryptable name', () async {
      final vaultId = await model.createVault(name: '  工作库  ');

      final vault = await repos.vaults.findById(vaultId);
      expect(vault, isNotNull);

      final name = await EncryptedNameCodec.decrypt(vault!.name);
      expect(name, '工作库');
    });

    test('firstActiveVaultId returns null when empty', () async {
      expect(await model.firstActiveVaultId(), isNull);
    });

    test('firstActiveVaultId returns first active vault', () async {
      final first = await model.createVault(name: 'A');
      await model.createVault(name: 'B');

      expect(await model.firstActiveVaultId(), first);
    });
  });
}

import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late StorageRepositories repos;
  late CipherAddModel model;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Cryptography.instance = Cryptography.instance.withRandom(
      SecureRandom.forTesting(seed: 13),
    );
    AppCrypto.reset();
    AppCrypto.init(secretKeyBytes: List<int>.filled(32, 5));

    db = AppDatabase.memory();
    repos = StorageRepositories(db);
    model = CipherAddModel(repos);
  });

  tearDown(() async {
    AppCrypto.reset();
    await db.close();
  });

  Future<void> seedVault({
    required String vaultUuid,
    required String name,
  }) async {
    final now = DateTime.utc(2026, 3, 1, 12);
    await db
        .into(db.vaults)
        .insert(
          VaultsCompanion.insert(
            vaultUuid: vaultUuid,
            name: await EncryptedNameCodec.encrypt(name),
            iconName: const Value('person'),
            syncRevision: now,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  group('CipherAddModel', () {
    test('save on empty database creates default vault and cipher', () async {
      final cipherUuid = await model.saveWebsiteLoginCipher(
        preferredVaultId: null,
        title: 'GitHub',
        username: 'cyr@example.com',
        password: 'secret123',
        website: 'https://github.com/login',
        notes: '工作账号',
      );

      final vaults = await repos.vaults.findAll();
      expect(vaults, hasLength(1));

      final vaultName = await EncryptedNameCodec.decrypt(vaults.first.name);
      expect(vaultName, '我的保险库');

      final ciphers = await repos.cipherEntries.findAll();
      expect(ciphers, hasLength(1));
      expect(ciphers.first.cipherUuid, cipherUuid);
      expect(ciphers.first.vaultUuid, vaults.first.vaultUuid);
      expect(ciphers.first.folderUuid, isNull);
      expect(ciphers.first.type, CipherType.websiteLogin);
    });

    test('save with existing vault does not create another vault', () async {
      await seedVault(vaultUuid: 'vault-work', name: '工作库');

      await model.saveWebsiteLoginCipher(
        preferredVaultId: 'vault-work',
        title: 'Notion',
        username: 'user@corp.com',
        password: 'pass',
        website: 'notion.so',
        notes: '',
      );

      final vaults = await repos.vaults.findAll();
      expect(vaults, hasLength(1));
      expect(vaults.first.vaultUuid, 'vault-work');

      final ciphers = await repos.cipherEntries.findAll();
      expect(ciphers, hasLength(1));
      expect(ciphers.first.vaultUuid, 'vault-work');
    });

    test('overview and full_data blobs decrypt to expected fields', () async {
      await model.saveWebsiteLoginCipher(
        preferredVaultId: null,
        title: '  Example Site  ',
        username: '  alice  ',
        password: 'pw',
        website: 'https://www.example.com/path?q=1',
        notes: 'note text',
      );

      final cipher = (await repos.cipherEntries.findAll()).single;

      final overview = await CipherOverviewCodec.decrypt(cipher.overviewBlob);
      expect(overview.title, 'Example Site');
      expect(overview.subtitle, 'alice');
      expect(overview.host, 'www.example.com');

      final payload = await CipherFullDataCodec.decryptWebsiteLogin(
        cipher.fullDataBlob,
      );
      expect(payload.username, 'alice');
      expect(payload.password, 'pw');
      expect(payload.notes, 'note text');
    });

    test('parseWebsiteHost handles bare domain and invalid URL', () {
      expect(CipherAddModel.parseWebsiteHost('github.com'), 'github.com');
      expect(
        CipherAddModel.parseWebsiteHost('https://api.github.com/repos'),
        'api.github.com',
      );
      expect(CipherAddModel.parseWebsiteHost(''), isNull);
      expect(CipherAddModel.parseWebsiteHost('   '), isNull);
    });
  });
}

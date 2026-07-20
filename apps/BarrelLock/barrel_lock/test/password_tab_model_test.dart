import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late StorageRepositories repos;
  late PasswordTabModel model;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Cryptography.instance = Cryptography.instance.withRandom(
      SecureRandom.forTesting(seed: 11),
    );
    AppCrypto.reset();
    AppCrypto.init(secretKeyBytes: List<int>.filled(32, 4));

    db = AppDatabase.memory();
    repos = StorageRepositories(db);
    model = PasswordTabModel(repos);
  });

  tearDown(() async {
    AppCrypto.reset();
    await db.close();
  });

  Future<void> seedSampleData() async {
    final now = DateTime.utc(2026, 3, 1, 12);

    await db
        .into(db.vaults)
        .insert(
          VaultsCompanion.insert(
            vaultUuid: 'vault-1',
            name: await EncryptedNameCodec.encrypt('个人库'),
            iconName: const Value('person'),
            syncRevision: now,
            createdAt: now,
            updatedAt: now,
          ),
        );

    await db
        .into(db.folders)
        .insert(
          FoldersCompanion.insert(
            folderUuid: 'folder-social',
            vaultUuid: 'vault-1',
            name: await EncryptedNameCodec.encrypt('社交账号'),
            syncRevision: now,
            createdAt: now,
            updatedAt: now,
          ),
        );

    final overviewGithub = await CipherOverviewCodec.encrypt(
      const CipherOverviewData(
        title: 'GitHub',
        subtitle: 'cyr@example.com',
        host: 'github.com',
        hasTotp: true,
      ),
    );
    final overviewTwitter = await CipherOverviewCodec.encrypt(
      const CipherOverviewData(
        title: 'X (Twitter)',
        subtitle: '@cyr_dev',
        host: 'x.com',
      ),
    );
    final dummyFull = await AppCrypto.encrypt([0]);

    await db
        .into(db.cipherEntries)
        .insert(
          CipherEntriesCompanion.insert(
            cipherUuid: 'cipher-github',
            vaultUuid: 'vault-1',
            folderUuid: const Value('folder-social'),
            type: CipherType.websiteLogin,
            overviewBlob: overviewGithub,
            fullDataBlob: Uint8List.fromList(dummyFull.bytes),
            isFavorite: const Value(true),
            syncRevision: now,
            createdAt: now,
            updatedAt: now,
          ),
        );

    await db
        .into(db.cipherEntries)
        .insert(
          CipherEntriesCompanion.insert(
            cipherUuid: 'cipher-twitter',
            vaultUuid: 'vault-1',
            folderUuid: const Value('folder-social'),
            type: CipherType.websiteLogin,
            overviewBlob: overviewTwitter,
            fullDataBlob: Uint8List.fromList(dummyFull.bytes),
            syncRevision: now,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  group('PasswordTabModel', () {
    test('loadVaultData returns empty when database is empty', () async {
      final data = await model.loadVaultData();

      expect(data.vaults, isEmpty);
      expect(data.ciphers, isEmpty);
    });

    test(
      'loadVaultData loads first vault ciphers when selectedVaultId is null',
      () async {
        await seedSampleData();

        final data = await model.loadVaultData();

        expect(data.vaults, hasLength(1));
        expect(data.ciphers, hasLength(2));
      },
    );

    test('watchDataChanges emits when cipher inserted', () async {
      await seedSampleData();

      final events = <void>[];
      final sub = model.watchDataChanges('vault-1').listen(events.add);

      final overview = await CipherOverviewCodec.encrypt(
        const CipherOverviewData(title: 'Notion', subtitle: 'user@corp.com'),
      );
      final dummyFull = await AppCrypto.encrypt([0]);
      final now = DateTime.utc(2026, 3, 1, 13);

      await db
          .into(db.cipherEntries)
          .insert(
            CipherEntriesCompanion.insert(
              cipherUuid: 'cipher-notion',
              vaultUuid: 'vault-1',
              type: CipherType.websiteLogin,
              overviewBlob: overview,
              fullDataBlob: Uint8List.fromList(dummyFull.bytes),
              syncRevision: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(events, isNotEmpty);
      await sub.cancel();
    });

    test('loadVaultData decrypts vaults folders and ciphers', () async {
      await seedSampleData();

      final data = await model.loadVaultData(selectedVaultId: 'vault-1');

      expect(data.vaults, hasLength(1));
      expect(data.vaults.first.name, '个人库');
      expect(data.ciphers, hasLength(2));
      expect(data.folderNames['folder-social'], '社交账号');
    });

    test('buildFolderGroups filters favorites', () async {
      await seedSampleData();
      final data = await model.loadVaultData(selectedVaultId: 'vault-1');

      final groups = model.buildFolderGroups(
        ciphers: data.ciphers,
        folderNames: data.folderNames,
        filter: VaultQuickFilter.favorites,
        searchQuery: '',
      );

      final items = groups.expand((g) => g.items).toList();
      expect(items, hasLength(1));
      expect(items.first.id, 'cipher-github');
    });

    test('buildFolderGroups search by title', () async {
      await seedSampleData();
      final data = await model.loadVaultData(selectedVaultId: 'vault-1');

      final groups = model.buildFolderGroups(
        ciphers: data.ciphers,
        folderNames: data.folderNames,
        filter: VaultQuickFilter.all,
        searchQuery: 'github',
      );

      final items = groups.expand((g) => g.items).toList();
      expect(items, hasLength(1));
      expect(items.first.title, 'GitHub');
    });

    test('toggleFavorite persists to database', () async {
      await seedSampleData();

      await model.toggleFavorite('cipher-twitter');

      final row = await repos.cipherEntries.findById('cipher-twitter');
      expect(row?.isFavorite, isTrue);
    });
  });
}

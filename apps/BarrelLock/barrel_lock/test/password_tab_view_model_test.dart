import 'dart:typed_data';

import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late StorageRepositories repos;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Cryptography.instance = Cryptography.instance.withRandom(
      SecureRandom.forTesting(seed: 21),
    );
    AppCrypto.reset();
    AppCrypto.init(secretKeyBytes: List<int>.filled(32, 3));

    db = AppDatabase.memory();
    repos = StorageRepositories(db);
  });

  tearDown(() async {
    AppCrypto.reset();
    await db.close();
  });

  test('PasswordTabViewModel leaves loading with empty database', () async {
    final container = ProviderContainer(
      overrides: [storageRepositoriesProvider.overrideWithValue(repos)],
    );
    addTearDown(container.dispose);

    AsyncValue<PasswordTabViewState> state = container.read(
      passwordTabViewModelProvider,
    );
    expect(state, isA<AsyncLoading<PasswordTabViewState>>());

    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    state = container.read(passwordTabViewModelProvider);
    expect(state, isA<AsyncData<PasswordTabViewState>>());
    expect(state.requireValue.vaults, isEmpty);
    expect(state.requireValue.title, '密码');
  });

  test('PasswordTabViewModel refreshes after cipher insert', () async {
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

    final container = ProviderContainer(
      overrides: [storageRepositoriesProvider.overrideWithValue(repos)],
    );
    addTearDown(container.dispose);

    await container.read(passwordTabViewModelProvider.future);
    expect(
      container.read(passwordTabViewModelProvider).requireValue.totalItemCount,
      0,
    );

    final overview = await CipherOverviewCodec.encrypt(
      const CipherOverviewData(title: 'GitHub', subtitle: 'cyr@example.com'),
    );
    final dummyFull = await AppCrypto.encrypt([0]);

    await db
        .into(db.cipherEntries)
        .insert(
          CipherEntriesCompanion.insert(
            cipherUuid: 'cipher-github',
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
    await Future<void>.delayed(Duration.zero);

    final state = container.read(passwordTabViewModelProvider).requireValue;
    expect(state.totalItemCount, 1);
    expect(state.folderGroups.single.items.single.title, 'GitHub');
  });
}

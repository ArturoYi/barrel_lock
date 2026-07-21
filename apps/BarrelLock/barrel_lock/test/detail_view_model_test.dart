import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

final class _RecordingDetailCoordinator implements DetailCoordinatorGateway {
  int popCount = 0;

  @override
  void pop() => popCount++;
}

void main() {
  late AppDatabase db;
  late StorageRepositories repos;
  late CipherAddModel addModel;
  late String cipherUuid;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Cryptography.instance = Cryptography.instance.withRandom(
      SecureRandom.forTesting(seed: 31),
    );
    AppCrypto.reset();
    AppCrypto.init(secretKeyBytes: List<int>.filled(32, 7));

    db = AppDatabase.memory();
    repos = StorageRepositories(db);
    addModel = CipherAddModel(repos, VaultManageModel(repos));
    cipherUuid = await addModel.saveWebsiteLoginCipher(
      preferredVaultId: null,
      title: 'Site',
      username: 'user',
      password: 'pass',
      website: 'example.com',
      notes: '',
    );
  });

  tearDown(() async {
    AppCrypto.reset();
    await db.close();
  });

  ProviderContainer createContainer({DetailCoordinatorGateway? coordinator}) {
    return ProviderContainer(
      overrides: [
        storageRepositoriesProvider.overrideWithValue(repos),
        detailCoordinatorProvider.overrideWithValue(
          coordinator ?? _RecordingDetailCoordinator(),
        ),
      ],
    );
  }

  Future<void> waitForLoaded(ProviderContainer container) async {
    for (var i = 0; i < 50; i++) {
      await Future<void>.delayed(Duration.zero);
      if (!container.read(detailViewModelProvider(cipherUuid)).isLoading) {
        return;
      }
    }
  }

  group('DetailViewModel', () {
    test('loads cipher detail on build', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      final sub = container.listen(
        detailViewModelProvider(cipherUuid),
        (_, _) {},
      );
      addTearDown(sub.close);

      await waitForLoaded(container);

      final state = container.read(detailViewModelProvider(cipherUuid));
      expect(state.isLoading, isFalse);
      expect(state.data?.overview.title, 'Site');
    });

    test('onSaveEdit with invalid form sets validation message', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      final sub = container.listen(
        detailViewModelProvider(cipherUuid),
        (_, _) {},
      );
      addTearDown(sub.close);

      await waitForLoaded(container);
      final notifier = container.read(
        detailViewModelProvider(cipherUuid).notifier,
      );
      notifier.onStartEdit();
      notifier.onPasswordChanged('');

      await notifier.onSaveEdit();
      final state = container.read(detailViewModelProvider(cipherUuid));
      expect(state.editFormState?.validationMessage, isNotNull);
    });

    test('onCancelEdit restores read-only mode', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      final sub = container.listen(
        detailViewModelProvider(cipherUuid),
        (_, _) {},
      );
      addTearDown(sub.close);

      await waitForLoaded(container);
      final notifier = container.read(
        detailViewModelProvider(cipherUuid).notifier,
      );
      notifier.onStartEdit();
      notifier.onTitleChanged('Changed');
      notifier.onCancelEdit();

      final state = container.read(detailViewModelProvider(cipherUuid));
      expect(state.isEditing, isFalse);
      expect(state.data?.overview.title, 'Site');
    });

    test('onDeleteConfirmed pops coordinator', () async {
      final coordinator = _RecordingDetailCoordinator();
      final container = createContainer(coordinator: coordinator);
      addTearDown(container.dispose);
      final sub = container.listen(
        detailViewModelProvider(cipherUuid),
        (_, _) {},
      );
      addTearDown(sub.close);

      await waitForLoaded(container);
      await container
          .read(detailViewModelProvider(cipherUuid).notifier)
          .onDeleteConfirmed();
      expect(coordinator.popCount, 1);
    });
  });
}

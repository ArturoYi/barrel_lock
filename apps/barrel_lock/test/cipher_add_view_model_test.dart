import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

final class _RecordingCipherAddCoordinator
    implements CipherAddCoordinatorGateway {
  int popCount = 0;
  int finishAddSuccessCount = 0;

  @override
  void pop() => popCount++;

  @override
  void finishAddSuccess() => finishAddSuccessCount++;
}

void main() {
  late AppDatabase db;
  late StorageRepositories repos;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Cryptography.instance = Cryptography.instance.withRandom(
      SecureRandom.forTesting(seed: 17),
    );
    AppCrypto.reset();
    AppCrypto.init(secretKeyBytes: List<int>.filled(32, 9));

    db = AppDatabase.memory();
    repos = StorageRepositories(db);
  });

  tearDown(() async {
    AppCrypto.reset();
    await db.close();
  });

  ProviderContainer createContainer({
    CipherAddCoordinatorGateway? coordinator,
    int initialType = CipherType.websiteLogin,
  }) {
    return ProviderContainer(
      overrides: [
        storageRepositoriesProvider.overrideWithValue(repos),
        cipherAddCoordinatorProvider.overrideWithValue(
          coordinator ?? _RecordingCipherAddCoordinator(),
        ),
        cipherAddInitialTypeProvider.overrideWithValue(initialType),
      ],
    );
  }

  group('CipherAddViewModel', () {
    test('starts with form state for initial cipher type', () {
      final container = createContainer(initialType: CipherType.bankCard);
      addTearDown(container.dispose);

      final state = container.read(cipherAddViewModelProvider);
      expect(state, isA<BankCardFormState>());
      expect(state.cipherType, CipherType.bankCard);
    });

    test('onCipherTypeSelected switches form state and clears fields', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(cipherAddViewModelProvider.notifier);
      notifier.onTitleChanged('GitHub');
      notifier.onCipherTypeSelected(CipherType.secureNote);

      final state = container.read(cipherAddViewModelProvider);
      expect(state, isA<SecureNoteFormState>());
      expect((state as SecureNoteFormState).title, isEmpty);
    });

    test('onSave with invalid form sets validation and skips save', () async {
      final coordinator = _RecordingCipherAddCoordinator();
      final container = createContainer(coordinator: coordinator);
      addTearDown(container.dispose);

      final notifier = container.read(cipherAddViewModelProvider.notifier);
      await notifier.onSave();

      final state = container.read(cipherAddViewModelProvider);
      expect(state.validationMessage, isNotNull);
      expect(state.isSaving, isFalse);
      expect(coordinator.finishAddSuccessCount, 0);

      final ciphers = await repos.cipherEntries.findAll();
      expect(ciphers, isEmpty);
    });

    test('onSave website login persists cipher and finishes flow', () async {
      final coordinator = _RecordingCipherAddCoordinator();
      final container = createContainer(coordinator: coordinator);
      addTearDown(container.dispose);

      final notifier = container.read(cipherAddViewModelProvider.notifier);
      notifier.onTitleChanged('GitHub');
      notifier.onUsernameChanged('cyr@example.com');
      notifier.onPasswordChanged('secret123');
      await notifier.onSave();

      expect(coordinator.finishAddSuccessCount, 1);

      final ciphers = await repos.cipherEntries.findAll();
      expect(ciphers, hasLength(1));
      expect(ciphers.first.type, CipherType.websiteLogin);
    });

    test('onSave bank card persists cipher with type 2', () async {
      final coordinator = _RecordingCipherAddCoordinator();
      final container = createContainer(
        coordinator: coordinator,
        initialType: CipherType.bankCard,
      );
      addTearDown(container.dispose);

      final notifier = container.read(cipherAddViewModelProvider.notifier);
      notifier.onTitleChanged('招商银行');
      notifier.onCardholderNameChanged('张三');
      notifier.onCardNumberChanged('6222021234567890');
      notifier.onExpiryMonthChanged('12');
      notifier.onExpiryYearChanged('28');
      notifier.onCvvChanged('123');
      await notifier.onSave();

      expect(coordinator.finishAddSuccessCount, 1);

      final ciphers = await repos.cipherEntries.findAll();
      expect(ciphers, hasLength(1));
      expect(ciphers.first.type, CipherType.bankCard);
    });

    test('onSave app account persists cipher with type 6', () async {
      final coordinator = _RecordingCipherAddCoordinator();
      final container = createContainer(
        coordinator: coordinator,
        initialType: CipherType.appAccount,
      );
      addTearDown(container.dispose);

      final notifier = container.read(cipherAddViewModelProvider.notifier);
      notifier.onTitleChanged('微信');
      notifier.onUsernameChanged('13800138000');
      notifier.onPasswordChanged('secret123');
      notifier.onPackageNameChanged('com.tencent.xin');
      await notifier.onSave();

      expect(coordinator.finishAddSuccessCount, 1);

      final ciphers = await repos.cipherEntries.findAll();
      expect(ciphers, hasLength(1));
      expect(ciphers.first.type, CipherType.appAccount);
    });

    test('onCancel delegates to coordinator when not saving', () {
      final coordinator = _RecordingCipherAddCoordinator();
      final container = createContainer(coordinator: coordinator);
      addTearDown(container.dispose);

      container.read(cipherAddViewModelProvider.notifier).onCancel();

      expect(coordinator.popCount, 1);
    });

    test('invalidate restores empty form for next entry', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(cipherAddViewModelProvider.notifier);
      notifier.onTitleChanged('GitHub');
      expect(
        (container.read(cipherAddViewModelProvider) as WebsiteLoginFormState)
            .title,
        'GitHub',
      );

      container.invalidate(cipherAddViewModelProvider);

      final state = container.read(cipherAddViewModelProvider);
      expect(state, isA<WebsiteLoginFormState>());
      expect((state as WebsiteLoginFormState).title, isEmpty);
    });
  });
}

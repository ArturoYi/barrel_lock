import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late StorageRepositories repos;
  late VaultManageModel vaultManage;
  late CipherAddModel addModel;
  late CipherDetailModel detailModel;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Cryptography.instance = Cryptography.instance.withRandom(
      SecureRandom.forTesting(seed: 21),
    );
    AppCrypto.reset();
    AppCrypto.init(secretKeyBytes: List<int>.filled(32, 3));

    db = AppDatabase.memory();
    repos = StorageRepositories(db);
    vaultManage = VaultManageModel(repos);
    addModel = CipherAddModel(repos, vaultManage);
    detailModel = CipherDetailModel(repos);
  });

  tearDown(() async {
    AppCrypto.reset();
    await db.close();
  });

  group('CipherDetailModel', () {
    test('loadCipherDetail decrypts website login cipher', () async {
      final cipherUuid = await addModel.saveWebsiteLoginCipher(
        preferredVaultId: null,
        title: 'GitHub',
        username: 'user@example.com',
        password: 'secret',
        website: 'github.com',
        notes: 'note',
      );

      final detail = await detailModel.loadCipherDetail(cipherUuid);
      expect(detail.overview.title, 'GitHub');
      expect(detail.fullData, isA<WebsiteLoginCipherPayload>());
      final payload = detail.fullData as WebsiteLoginCipherPayload;
      expect(payload.username, 'user@example.com');
      expect(payload.password, 'secret');
      expect(payload.notes, 'note');
    });

    test('loadCipherDetail throws for missing cipher', () async {
      expect(
        () => detailModel.loadCipherDetail('missing-id'),
        throwsA(isA<CipherDetailException>()),
      );
    });

    test('updateFromFormState updates blobs in place', () async {
      final cipherUuid = await addModel.saveWebsiteLoginCipher(
        preferredVaultId: null,
        title: 'Old',
        username: 'old@example.com',
        password: 'old-pass',
        website: 'old.com',
        notes: '',
      );

      await detailModel.updateFromFormState(
        cipherUuid: cipherUuid,
        formState: const WebsiteLoginFormState(
          title: 'New Title',
          username: 'new@example.com',
          password: 'new-pass',
          website: 'new.com',
          notes: 'updated',
        ),
      );

      final detail = await detailModel.loadCipherDetail(cipherUuid);
      expect(detail.overview.title, 'New Title');
      final payload = detail.fullData as WebsiteLoginCipherPayload;
      expect(payload.username, 'new@example.com');
      expect(payload.password, 'new-pass');
      expect(detail.cipherUuid, cipherUuid);
    });

    test('updateFolder and softDelete', () async {
      final vaultId = await vaultManage.createVault(name: '工作');
      final folderId = await FolderManageModel(
        repos,
      ).createFolder(vaultUuid: vaultId, name: '社交');
      final cipherUuid = await addModel.saveWebsiteLoginCipher(
        preferredVaultId: vaultId,
        title: 'Site',
        username: 'u',
        password: 'p',
        website: 'x.com',
        notes: '',
      );

      await detailModel.updateFolder(cipherUuid, folderId);
      var detail = await detailModel.loadCipherDetail(cipherUuid);
      expect(detail.folderUuid, folderId);
      expect(detail.folderName, '社交');

      await detailModel.softDelete(cipherUuid);
      expect(
        () => detailModel.loadCipherDetail(cipherUuid),
        throwsA(isA<CipherDetailException>()),
      );
    });
  });

  group('CipherAddFormStateFactory.fromCipherDetail', () {
    test('maps website login payload', () {
      const overview = CipherOverviewData(
        title: 'GitHub',
        subtitle: 'user',
        host: 'github.com',
      );
      const fullData = WebsiteLoginCipherPayload(
        username: 'user',
        password: 'pass',
        notes: 'n',
      );

      final form = CipherAddFormStateFactory.fromCipherDetail(
        overview: overview,
        fullData: fullData,
      );

      expect(form, isA<WebsiteLoginFormState>());
      final website = form as WebsiteLoginFormState;
      expect(website.title, 'GitHub');
      expect(website.username, 'user');
      expect(website.password, 'pass');
      expect(website.website, 'github.com');
    });

    test('maps bank card payload', () {
      const overview = CipherOverviewData(title: 'Card', subtitle: '1234');
      const fullData = BankCardCipherPayload(
        cardholderName: 'CYR',
        cardNumber: '4111111111111111',
        expiryMonth: '12',
        expiryYear: '30',
        cvv: '123',
      );

      final form = CipherAddFormStateFactory.fromCipherDetail(
        overview: overview,
        fullData: fullData,
      );

      expect(form, isA<BankCardFormState>());
      final card = form as BankCardFormState;
      expect(card.cardNumber, '4111111111111111');
      expect(card.cvv, '123');
    });
  });
}

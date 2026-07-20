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
      SecureRandom.forTesting(seed: 31),
    );
    AppCrypto.reset();
    AppCrypto.init(secretKeyBytes: List<int>.filled(32, 6));

    db = AppDatabase.memory();
    repos = StorageRepositories(db);
    model = CipherAddModel(repos);
  });

  tearDown(() async {
    AppCrypto.reset();
    await db.close();
  });

  Future<void> seedVault() async {
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
  }

  group('CipherAddModel all types', () {
    test('saveBankCardCipher writes type 2 with overview subtitle', () async {
      await seedVault();
      await model.saveBankCardCipher(
        preferredVaultId: 'vault-1',
        title: '招商银行',
        cardholderName: '张三',
        cardNumber: '6222 0212 3456 7890',
        expiryMonth: '12',
        expiryYear: '28',
        cvv: '123',
        pin: '',
        notes: '',
      );

      final cipher = (await repos.cipherEntries.findAll()).single;
      expect(cipher.type, CipherType.bankCard);

      final overview = await CipherOverviewCodec.decrypt(cipher.overviewBlob);
      expect(overview.title, '招商银行');
      expect(overview.subtitle, '7890');

      final payload =
          await CipherFullDataCodec.decrypt(cipher.fullDataBlob)
              as BankCardCipherPayload;
      expect(payload.cardNumber, '6222021234567890');
    });

    test('saveIdentityDocumentCipher writes type 3', () async {
      await seedVault();
      await model.saveIdentityDocumentCipher(
        preferredVaultId: 'vault-1',
        title: '身份证',
        documentType: '身份证',
        fullName: '张三',
        documentNumber: '110101199001011234',
        issueDate: '2020-01-01',
        expiryDate: '2030-01-01',
        notes: '',
      );

      final cipher = (await repos.cipherEntries.findAll()).single;
      expect(cipher.type, CipherType.identityDocument);
      final payload = await CipherFullDataCodec.decrypt(cipher.fullDataBlob);
      expect(payload, isA<IdentityDocumentCipherPayload>());
    });

    test('saveSecureNoteCipher writes type 4', () async {
      await seedVault();
      await model.saveSecureNoteCipher(
        preferredVaultId: 'vault-1',
        title: 'Wi-Fi 密码',
        content: 'MySecretWifiPass',
        notes: '',
      );

      final cipher = (await repos.cipherEntries.findAll()).single;
      expect(cipher.type, CipherType.secureNote);
    });

    test('saveSshKeyCipher writes type 5 with host in overview', () async {
      await seedVault();
      await model.saveSshKeyCipher(
        preferredVaultId: 'vault-1',
        title: 'GitHub Deploy',
        privateKey: '-----BEGIN OPENSSH PRIVATE KEY-----\nkey',
        publicKey: 'ssh-ed25519 AAAA',
        passphrase: '',
        host: 'github.com',
        username: 'git',
        notes: '',
      );

      final cipher = (await repos.cipherEntries.findAll()).single;
      expect(cipher.type, CipherType.sshKey);

      final overview = await CipherOverviewCodec.decrypt(cipher.overviewBlob);
      expect(overview.subtitle, 'git@github.com');
      expect(overview.host, 'github.com');
    });

    test(
      'saveAppAccountCipher writes type 6 with package in overview',
      () async {
        await seedVault();
        await model.saveAppAccountCipher(
          preferredVaultId: 'vault-1',
          title: '微信',
          username: '13800138000',
          password: 'secret',
          packageName: 'com.tencent.xin',
          notes: '',
        );

        final cipher = (await repos.cipherEntries.findAll()).single;
        expect(cipher.type, CipherType.appAccount);

        final overview = await CipherOverviewCodec.decrypt(cipher.overviewBlob);
        expect(overview.title, '微信');
        expect(overview.subtitle, '13800138000');
        expect(overview.host, 'com.tencent.xin');

        final payload =
            await CipherFullDataCodec.decrypt(cipher.fullDataBlob)
                as AppAccountCipherPayload;
        expect(payload.packageName, 'com.tencent.xin');
      },
    );
  });
}

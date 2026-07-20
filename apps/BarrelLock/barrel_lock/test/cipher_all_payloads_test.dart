import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    Cryptography.instance = Cryptography.instance.withRandom(
      SecureRandom.forTesting(seed: 21),
    );
    AppCrypto.reset();
    AppCrypto.init(secretKeyBytes: List<int>.filled(32, 3));
  });

  tearDown(AppCrypto.reset);

  group('All cipher payloads codec roundtrip', () {
    test('WebsiteLoginCipherPayload', () async {
      const payload = WebsiteLoginCipherPayload(
        username: 'user@example.com',
        password: 'pass',
        notes: 'note',
      );
      await _expectRoundtrip(payload, CipherType.websiteLogin);
    });

    test('BankCardCipherPayload', () async {
      const payload = BankCardCipherPayload(
        cardholderName: '张三',
        cardNumber: '6222021234567890',
        expiryMonth: '12',
        expiryYear: '28',
        cvv: '123',
        pin: '1234',
      );
      await _expectRoundtrip(payload, CipherType.bankCard);
    });

    test('IdentityDocumentCipherPayload', () async {
      const payload = IdentityDocumentCipherPayload(
        documentType: '身份证',
        fullName: '张三',
        documentNumber: '110101199001011234',
        issueDate: '2020-01-01',
        expiryDate: '2030-01-01',
      );
      await _expectRoundtrip(payload, CipherType.identityDocument);
    });

    test('SecureNoteCipherPayload', () async {
      const payload = SecureNoteCipherPayload(content: '机密笔记内容', notes: '附加');
      await _expectRoundtrip(payload, CipherType.secureNote);
    });

    test('SshKeyCipherPayload', () async {
      const payload = SshKeyCipherPayload(
        privateKey: '-----BEGIN OPENSSH PRIVATE KEY-----\nabc',
        publicKey: 'ssh-ed25519 AAAA',
        passphrase: 'secret',
        host: 'github.com',
        username: 'git',
      );
      await _expectRoundtrip(payload, CipherType.sshKey);
    });

    test('AppAccountCipherPayload', () async {
      const payload = AppAccountCipherPayload(
        username: '13800138000',
        password: 'secret',
        packageName: 'com.tencent.xin',
        notes: '工作号',
      );
      await _expectRoundtrip(payload, CipherType.appAccount);
    });
  });
}

Future<void> _expectRoundtrip(
  CipherFullDataPayload payload,
  int expectedType,
) async {
  final blob = await CipherFullDataCodec.encrypt(payload);
  final decoded = await CipherFullDataCodec.decrypt(blob);
  expect(decoded.type, expectedType);
  expect(decoded.toJson(), payload.toJson());
}

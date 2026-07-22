import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final testKey = List<int>.filled(32, 9);

  setUp(() {
    Cryptography.instance = Cryptography.instance.withRandom(
      SecureRandom.forTesting(seed: 7),
    );
    AppCrypto.reset();
    AppCrypto.init(secretKeyBytes: testKey);
  });

  tearDown(AppCrypto.reset);

  group('CipherFullDataCodec', () {
    test('encryptWebsiteLogin-decryptWebsiteLogin roundtrip', () async {
      const payload = WebsiteLoginCipherPayload(
        username: 'cyr@example.com',
        password: 'secret',
        notes: '工作账号',
      );

      final blob = await CipherFullDataCodec.encryptWebsiteLogin(payload);
      final decoded = await CipherFullDataCodec.decryptWebsiteLogin(blob);

      expect(decoded.username, payload.username);
      expect(decoded.password, payload.password);
      expect(decoded.notes, payload.notes);
    });

    test('decryptWebsiteLogin throws on tampered blob', () async {
      const payload = WebsiteLoginCipherPayload(
        username: 'user',
        password: 'pass',
      );
      final blob = await CipherFullDataCodec.encryptWebsiteLogin(payload);
      blob[0] ^= 0xff;

      expect(
        () => CipherFullDataCodec.decryptWebsiteLogin(blob),
        throwsA(isA<Object>()),
      );
    });

    test('fromJson applies defaults for missing notes', () async {
      const payload = WebsiteLoginCipherPayload(
        username: 'only-user',
        password: 'only-pass',
      );

      final blob = await CipherFullDataCodec.encryptWebsiteLogin(payload);
      final decoded = await CipherFullDataCodec.decryptWebsiteLogin(blob);

      expect(decoded.username, 'only-user');
      expect(decoded.password, 'only-pass');
      expect(decoded.notes, isNull);
    });

    test('encrypt-decrypt dispatches via generic API', () async {
      const payload = WebsiteLoginCipherPayload(
        username: 'user',
        password: 'pass',
      );

      final blob = await CipherFullDataCodec.encrypt(payload);
      final decoded = await CipherFullDataCodec.decrypt(blob);

      expect(decoded, isA<WebsiteLoginCipherPayload>());
      expect(decoded.type, CipherType.websiteLogin);
    });
  });
}

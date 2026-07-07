import 'dart:convert';

import 'package:core/core.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final testKey = List<int>.filled(AppCrypto.secretKeyLength, 7);

  group('AppCrypto', () {
    setUp(() {
      Cryptography.instance = Cryptography.instance.withRandom(
        SecureRandom.forTesting(seed: 42),
      );
      AppCrypto.reset();
    });

    tearDown(() {
      AppCrypto.reset();
    });

    test('throws when accessed before init', () async {
      await expectLater(AppCrypto.encrypt([1]), throwsA(isA<StateError>()));
    });

    test('rejects invalid key length', () {
      expect(
        () => AppCrypto.init(secretKeyBytes: [1, 2, 3]),
        throwsArgumentError,
      );
    });

    test('rejects duplicate init', () {
      AppCrypto.init(secretKeyBytes: testKey);
      expect(() => AppCrypto.init(secretKeyBytes: testKey), throwsStateError);
    });

    test('encrypt/decrypt bytes roundtrip', () async {
      AppCrypto.init(secretKeyBytes: testKey);

      final plainText = utf8.encode('hello, barrel lock');
      final payload = await AppCrypto.encrypt(plainText);
      final decrypted = await AppCrypto.decrypt(payload);

      expect(payload.bytes, isNot(equals(plainText)));
      expect(decrypted, plainText);
    });

    test('encrypt/decrypt string roundtrip via base64', () async {
      AppCrypto.init(secretKeyBytes: testKey);

      const plainText = '敏感配置项';
      final encrypted = await AppCrypto.encryptString(plainText);
      final decrypted = await AppCrypto.decryptString(encrypted);

      expect(encrypted, isNot(equals(plainText)));
      expect(decrypted, plainText);
    });

    test('EncryptedPayload roundtrips through base64', () async {
      AppCrypto.init(secretKeyBytes: testKey);

      final payload = await AppCrypto.encrypt([1, 2, 3]);
      final restored = EncryptedPayload.fromBase64(payload.toBase64());
      final decrypted = await AppCrypto.decrypt(restored);

      expect(decrypted, [1, 2, 3]);
    });

    test('decrypt fails when ciphertext is tampered', () async {
      AppCrypto.init(secretKeyBytes: testKey);

      final payload = await AppCrypto.encrypt([9, 9, 9]);
      final tampered = EncryptedPayload(
        List<int>.from(payload.bytes)..[0] ^= 0xff,
      );

      expect(
        () => AppCrypto.decrypt(tampered),
        throwsA(isA<SecretBoxAuthenticationError>()),
      );
    });

    test('decrypt fails with wrong key', () async {
      AppCrypto.init(secretKeyBytes: testKey);
      final payload = await AppCrypto.encrypt([4, 5, 6]);

      AppCrypto.reset();
      AppCrypto.init(
        secretKeyBytes: List<int>.filled(AppCrypto.secretKeyLength, 8),
      );

      expect(
        () => AppCrypto.decrypt(payload),
        throwsA(isA<SecretBoxAuthenticationError>()),
      );
    });
  });
}

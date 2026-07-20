import 'dart:typed_data';

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

  group('CipherOverviewCodec', () {
    test('encrypt-decrypt roundtrip', () async {
      const data = CipherOverviewData(
        title: 'GitHub',
        subtitle: 'cyr@example.com',
        host: 'github.com',
        hasTotp: true,
      );

      final blob = await CipherOverviewCodec.encrypt(data);
      final decoded = await CipherOverviewCodec.decrypt(blob);

      expect(decoded.title, data.title);
      expect(decoded.subtitle, data.subtitle);
      expect(decoded.host, data.host);
      expect(decoded.hasTotp, isTrue);
    });

    test('decryptOrFallback returns fallback on tampered blob', () async {
      const data = CipherOverviewData(title: 'Test', subtitle: 'sub');
      final blob = await CipherOverviewCodec.encrypt(data);
      blob[0] ^= 0xff;

      final decoded = await CipherOverviewCodec.decryptOrFallback(blob);

      expect(decoded, CipherOverviewData.fallback);
    });

    test('fromJson applies defaults for missing fields', () {
      final data = CipherOverviewData.fromJson({'title': 'Only Title'});

      expect(data.title, 'Only Title');
      expect(data.subtitle, isEmpty);
      expect(data.host, isNull);
      expect(data.hasTotp, isFalse);
    });
  });

  group('EncryptedNameCodec', () {
    test('encrypt-decrypt roundtrip', () async {
      final blob = await EncryptedNameCodec.encrypt('个人库');
      final name = await EncryptedNameCodec.decrypt(blob);

      expect(name, '个人库');
    });

    test('decryptOrFallback returns empty on invalid blob', () async {
      final name = await EncryptedNameCodec.decryptOrFallback(
        Uint8List.fromList([1, 2, 3]),
      );

      expect(name, isEmpty);
    });
  });
}

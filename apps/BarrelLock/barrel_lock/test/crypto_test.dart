import 'dart:convert';

import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    Cryptography.instance = Cryptography.instance.withRandom(
      SecureRandom.forTesting(seed: 42),
    );
    AppCrypto.reset();
    await SPStorage.init(
      appNamespace: 'barrel_lock',
      env: 'test',
      managedKeys: [
        ...PreferenceKeys.allKeys,
        ...BarrelLockPreferenceKeys.allKeys,
      ],
    );
    AppIdentityAuth.reset();
    AppIdentityAuth.init(
      config: const IdentityAuthConfig(
        pinStorageKey: PreferenceKeys.identityAuthPin,
        minPinLength: AppLockPinPolicy.length,
        maxPinLength: AppLockPinPolicy.length,
      ),
    );
  });

  tearDown(() {
    AppCrypto.reset();
    AppIdentityAuth.reset();
  });

  group('BarrelLockCrypto', () {
    test('init enables AppCrypto with fixed master key', () async {
      await BarrelLockCrypto.init();

      final payload = await AppCrypto.encrypt([1, 2, 3]);
      expect(await AppCrypto.decrypt(payload), [1, 2, 3]);
      expect(BarrelLockMasterKey.value.length, AppCrypto.secretKeyLength);
      expect(BarrelLockMasterKey.bytes, utf8.encode(BarrelLockMasterKey.value));
    });

    test('init is idempotent across AppCrypto reset', () async {
      await BarrelLockCrypto.init();
      final firstCipher = await AppCrypto.encryptString('persisted');

      AppCrypto.reset();
      await BarrelLockCrypto.init();

      expect(await AppCrypto.decryptString(firstCipher), 'persisted');
    });
  });

  group('BarrelLockEncryptedStorage', () {
    setUp(() async {
      await BarrelLockCrypto.init();
    });

    test('setString/getString roundtrip', () async {
      await BarrelLockEncryptedStorage.setString('demo_key', 'secret-value');

      expect(
        await BarrelLockEncryptedStorage.getString('demo_key'),
        'secret-value',
      );
      expect(SPStorage.getString('demo_key'), isNot('secret-value'));
    });

    test('getString returns null for missing key', () async {
      expect(await BarrelLockEncryptedStorage.getString('missing'), isNull);
    });
  });

  group('AppLockModel', () {
    setUp(() async {
      await BarrelLockCrypto.init();
    });

    test('loadEnabled returns false when no saved preferences', () async {
      const model = AppLockModel();
      expect(await model.loadEnabled(), isFalse);
    });

    test('saveEnabled roundtrip', () async {
      const model = AppLockModel();
      await model.saveEnabled(true);
      expect(await model.loadEnabled(), isTrue);
    });

    test('saveEnabled does not imply pin exists', () async {
      const model = AppLockModel();
      await model.saveEnabled(true);

      expect(await model.loadEnabled(), isTrue);
      expect(await AppIdentityAuth.hasAppPin(), isFalse);
    });

    test('saveFallbackPinHint roundtrip', () async {
      const model = AppLockModel();
      await model.saveFallbackPinHint('我的宠物叫小白');
      expect(await model.loadFallbackPinHint(), '我的宠物叫小白');
    });
  });
}

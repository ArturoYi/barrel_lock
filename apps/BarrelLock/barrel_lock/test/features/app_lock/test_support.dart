import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:core/identity_auth/biometric/noop_biometric_auth_adapter.dart';
import 'package:cryptography/cryptography.dart';
import 'package:cryptography/dart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const testAppLockPin = '123456';
const testAppLockPinAlt = '567890';
const testAppLockWrongPin = '000000';

Future<void> initAppLockTestEnvironment() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  AppCrypto.reset();
  AppIdentityAuth.reset();
  await SPStorage.init(
    appNamespace: 'barrel_lock',
    env: 'test',
    managedKeys: [
      ...PreferenceKeys.allKeys,
      ...BarrelLockPreferenceKeys.allKeys,
    ],
  );
  await BarrelLockCrypto.init();
  Cryptography.instance = DartCryptography.defaultInstance.withRandom(
    SecureRandom.forTesting(seed: 42),
  );
  AppIdentityAuth.init(
    config: const IdentityAuthConfig(
      pinStorageKey: PreferenceKeys.identityAuthPin,
      minPinLength: AppLockPinPolicy.length,
      maxPinLength: AppLockPinPolicy.length,
    ),
    biometricAdapter: const NoopBiometricAuthAdapter(),
  );
}

void resetAppLockTestEnvironment() {
  AppCrypto.reset();
  AppIdentityAuth.reset();
}

AppLockPreferencesRepository createTestPreferencesRepository({
  IdentityAuthUiDelegate? uiDelegate,
}) {
  return AppLockPreferencesRepository(
    model: const AppLockModel(),
    authService: AppLockAuthService(
      uiDelegate: uiDelegate ?? const _NoopUiDelegate(),
    ),
  );
}

/// 写入已启用应用保护 + 已配置 PIN 的测试夹具。
Future<void> seedEnabledAppLock() async {
  await AppIdentityAuth.setAppPin(testAppLockPin);
  await const AppLockModel().saveEnabled(true);
}

/// 轮询等待条件成立或超时失败。
Future<void> pollUntil({
  required bool Function() condition,
  Duration timeout = const Duration(seconds: 2),
  Duration interval = const Duration(milliseconds: 10),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (condition()) {
      return;
    }
    await Future<void>.delayed(interval);
  }
  fail('timed out waiting for condition');
}

/// 等待冷启动锁屏请求并完成验证（单测无 Overlay 层，需手动调用 [startAuthentication]）。
Future<void> waitForColdStartAuth(ProviderContainer container) async {
  await pollUntil(
    condition: () {
      final session = container.read(appLockSessionProvider);
      return session.isLocked && session.isAuthenticating;
    },
  );

  await container.read(appLockSessionProvider.notifier).startAuthentication();

  await pollUntil(
    condition: () {
      return !container.read(appLockSessionProvider).isAuthenticating;
    },
  );
}

/// 等待全局 PIN 遮罩出现。
Future<void> waitForPinPrompt(ProviderContainer container) {
  return pollUntil(
    condition: () => container.read(appLockPinPromptProvider) != null,
  );
}

appLockEnableSetupTestOverrides({
  AppLockEnableSetupCoordinatorGateway? coordinator,
}) {
  return [
    appLockEnableSetupCoordinatorProvider.overrideWithValue(
      coordinator ?? _NoopEnableSetupCoordinator(),
    ),
  ];
}

/// 模拟设置页 `ref.watch(appLockEnableSetupProvider)`，防止 autoDispose 在单测中断言前被销毁。
ProviderSubscription<AppLockEnableSetupState> keepAppLockEnableSetupAlive(
  ProviderContainer container,
) {
  return container.listen(appLockEnableSetupProvider, (_, _) {});
}

final class _NoopUiDelegate implements IdentityAuthUiDelegate {
  const _NoopUiDelegate();

  @override
  Future<String?> promptForAppPin({required IdentityAuthReason reason}) async {
    return null;
  }

  @override
  Future<void> onBiometricUnavailable({
    required IdentityAuthReason reason,
  }) async {}
}

final class _NoopEnableSetupCoordinator
    implements AppLockEnableSetupCoordinatorGateway {
  @override
  void onEnableSetupCancelled() {}

  @override
  void onEnableSetupCompleted() {}
}

final class QueueingUiDelegate implements IdentityAuthUiDelegate {
  QueueingUiDelegate(this.responses);

  final List<String?> responses;
  var callCount = 0;

  @override
  Future<String?> promptForAppPin({required IdentityAuthReason reason}) async {
    final index = callCount++;
    if (index >= responses.length) {
      return responses.last;
    }
    return responses[index];
  }

  @override
  Future<void> onBiometricUnavailable({
    required IdentityAuthReason reason,
  }) async {}
}

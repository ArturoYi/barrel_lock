import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'barrel_lock_app.dart';

/// 包装 [BarrelLockApp] 的 ProviderScope 构建器，供平台注入 overrides。
typedef BarrelLockScopeBuilder = Widget Function(Widget child);

/// 平台 app 向 [AppRouter] 注入 Page Widget 的回调。
typedef ConfigureBarrelLockRouter = void Function();

Widget _defaultScopeBuilder(Widget child) => ProviderScope(child: child);

/// BarrelLock 统一启动入口。
///
/// 平台 app 通过 [scopeBuilder] 注入差异（如 ATT、权限等）：
///
/// ```dart
/// runBarrelLockApp(
///   scopeBuilder: (child) => ProviderScope(
///     overrides: [
///       launchScreenPrepareProvider.overrideWith((_) => platformInit),
///     ],
///     child: child,
///   ),
/// );
/// ```
Future<void> runBarrelLockApp({
  required ConfigureBarrelLockRouter configureRouter,
  BarrelLockScopeBuilder scopeBuilder = _defaultScopeBuilder,
  String storageEnv = 'prod',
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await SPStorage.init(
    appNamespace: 'barrel_lock',
    env: storageEnv,
    managedKeys: [
      ...PreferenceKeys.allKeys,
      ...BarrelLockPreferenceKeys.allKeys,
    ],
  );
  await BarrelLockCrypto.init();
  AppIdentityAuth.init(
    config: const IdentityAuthConfig(
      pinStorageKey: PreferenceKeys.identityAuthPin,
      minPinLength: AppLockPinPolicy.length,
      maxPinLength: AppLockPinPolicy.length,
    ),
  );
  await AppDeviceInfo.init();
  configureRouter();
  await bootstrapBarrelLockLifecycle();
  runApp(scopeBuilder(const BarrelLockApp()));
}

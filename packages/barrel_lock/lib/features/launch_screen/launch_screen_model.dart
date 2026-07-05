import 'package:core/core.dart';

/// 平台可选的启动前初始化（如鉴权、预加载、ATT 等）。
typedef LaunchScreenPrepare = Future<void> Function();

/// 启动页业务数据与初始化（MVVM-C 的 M 层）。
final class LaunchScreenModel {
  LaunchScreenModel(this._prepare);

  final LaunchScreenPrepare _prepare;

  Future<void> prepare() => _prepare();
}

/// 默认空实现；平台 app 可在 [ProviderScope] 中 override。
final launchScreenPrepareProvider = Provider<LaunchScreenPrepare>(
  (_) => () async {},
);

final launchScreenModelProvider = Provider<LaunchScreenModel>((ref) {
  final prepare = ref.watch(launchScreenPrepareProvider);
  return LaunchScreenModel(prepare);
});

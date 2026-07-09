/// 锁屏保护用户偏好（MVVM-C 的 M 层数据契约）。
///
/// 仅描述「用户选择了什么」，不包含运行时锁屏状态（见 [AppLockSessionState]）。
/// [hasFallbackPin] 与 [AppIdentityAuth.hasAppPin] 应保持同步，由 Model / AuthService 维护。
final class AppLockPreferences {
  const AppLockPreferences({
    required this.enabled,
    required this.hasFallbackPin,
  });

  /// 是否启用锁屏保护（冷启动与后台恢复时触发验证）。
  final bool enabled;

  /// 是否已配置备用 PIN（镜像 [AppIdentityAuth.hasAppPin]，便于设置页展示）。
  final bool hasFallbackPin;

  AppLockPreferences copyWith({bool? enabled, bool? hasFallbackPin}) {
    return AppLockPreferences(
      enabled: enabled ?? this.enabled,
      hasFallbackPin: hasFallbackPin ?? this.hasFallbackPin,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AppLockPreferences &&
        other.enabled == enabled &&
        other.hasFallbackPin == hasFallbackPin;
  }

  @override
  int get hashCode => Object.hash(enabled, hasFallbackPin);
}

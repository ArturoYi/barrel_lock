/// 锁屏保护用户偏好（MVVM-C 的 M 层读模型）。
///
/// 仅描述「用户选择了什么」，不包含运行时锁屏状态（见 [AppLockSessionState]）。
/// [hasFallbackPin] 由 [AppLockPreferencesRepository.load] 从 [AppIdentityAuth.hasAppPin] 派生，不单独落盘。
final class AppLockPreferences {
  const AppLockPreferences({
    required this.enabled,
    required this.hasFallbackPin,
    this.fallbackPinHint,
  });

  /// 是否启用锁屏保护（冷启动与后台恢复时触发验证）。
  final bool enabled;

  /// 是否已配置备用 PIN（镜像 [AppIdentityAuth.hasAppPin]，便于设置页展示）。
  final bool hasFallbackPin;

  /// 忘记密码时的提示语；未设置时为 `null`。
  final String? fallbackPinHint;

  AppLockPreferences copyWith({
    bool? enabled,
    bool? hasFallbackPin,
    String? fallbackPinHint,
    bool clearFallbackPinHint = false,
  }) {
    return AppLockPreferences(
      enabled: enabled ?? this.enabled,
      hasFallbackPin: hasFallbackPin ?? this.hasFallbackPin,
      fallbackPinHint: clearFallbackPinHint
          ? null
          : (fallbackPinHint ?? this.fallbackPinHint),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AppLockPreferences &&
        other.enabled == enabled &&
        other.hasFallbackPin == hasFallbackPin &&
        other.fallbackPinHint == fallbackPinHint;
  }

  @override
  int get hashCode => Object.hash(enabled, hasFallbackPin, fallbackPinHint);
}

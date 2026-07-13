/// 应用保护 PIN 策略（全模块 SSOT）。
abstract final class AppLockPinPolicy {
  static const int length = 6;
  static const int hintMaxLength = 30;

  /// 校验 PIN 格式；返回 `null` 表示通过，否则为可展示错误文案。
  static String? validatePin(String pin) {
    if (!_isValidPin(pin.trim())) {
      return '请输入 $length 位数字密码';
    }
    return null;
  }

  /// 返回 `null` 表示通过；否则为可展示错误文案。
  static String? validateSetup({
    required String pin,
    required String confirmPin,
  }) {
    final trimmedPin = pin.trim();
    final trimmedConfirm = confirmPin.trim();

    if (!_isValidPin(trimmedPin)) {
      return '请输入 $length 位数字密码';
    }
    if (trimmedPin != trimmedConfirm) {
      return '两次输入不一致';
    }
    return null;
  }

  /// 校验忘记密码提示语。
  static String? validateHint(String hint) {
    final trimmed = hint.trim();
    if (trimmed.isEmpty) {
      return '请输入提示语';
    }
    if (trimmed.length > hintMaxLength) {
      return '提示语不能超过 $hintMaxLength 个字符';
    }
    return null;
  }

  /// 修改 PIN：校验当前密码 + 新密码格式与一致性。
  static String? validateChange({
    required String currentPin,
    required String pin,
    required String confirmPin,
  }) {
    final currentError = validateCurrentPin(currentPin);
    if (currentError != null) {
      return currentError;
    }

    final setupError = validateSetup(pin: pin, confirmPin: confirmPin);
    if (setupError != null) {
      return setupError;
    }

    if (pin.trim() == currentPin.trim()) {
      return '新密码不能与当前密码相同';
    }
    return null;
  }

  /// 校验「当前密码」非空。
  static String? validateCurrentPin(String currentPin) {
    if (currentPin.trim().isEmpty) {
      return '请输入当前密码';
    }
    return null;
  }

  static bool _isValidPin(String value) {
    return value.length == length && RegExp(r'^\d+$').hasMatch(value);
  }
}

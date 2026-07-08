/// 应用保护 PIN 策略（全模块 SSOT）。
abstract final class AppLockPinPolicy {
  static const int length = 6;

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

  static bool _isValidPin(String value) {
    return value.length == length && RegExp(r'^\d+$').hasMatch(value);
  }
}

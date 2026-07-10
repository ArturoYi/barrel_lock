/// PIN 步骤中，用户当前正在输入的密码框标识。
///
/// 开启验证流程第一步需要依次填写「密码」与「确认密码」两个框；
/// 自定义数字键盘始终向 [AppLockEnableSetupPinInputField.pin] 或
/// [AppLockEnableSetupPinInputField.confirmPin] 对应的缓冲写入内容。
enum AppLockEnableSetupPinInputField {
  /// 主密码输入框；填满 [AppLockPinPolicy.length] 位后自动切换到 [confirmPin]。
  pin,

  /// 确认密码输入框；退格至空时回退到 [pin] 并删除主密码末位。
  confirmPin,
}

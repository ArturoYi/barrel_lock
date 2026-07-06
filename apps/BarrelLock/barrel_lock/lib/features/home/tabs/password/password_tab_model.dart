import 'package:core/core.dart';

/// 首页「密码」Tab 业务数据（MVVM-C 的 M 层）。
final class PasswordTabModel {
  const PasswordTabModel();

  String get title => '密码';

  int get maxPinLength => 6;
}

final passwordTabModelProvider = Provider<PasswordTabModel>(
  (_) => const PasswordTabModel(),
);

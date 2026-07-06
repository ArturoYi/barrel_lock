import 'package:core/core.dart';

/// 设置页业务数据（MVVM-C 的 M 层）。
final class SettingsModel {
  const SettingsModel();
}

final settingsModelProvider = Provider<SettingsModel>(
  (_) => const SettingsModel(),
);

import 'package:core/core.dart';

/// 首页「设置」Tab 业务数据（MVVM-C 的 M 层）。
final class SettingsTabModel {
  const SettingsTabModel();

  String get title => '设置';
}

final settingsTabModelProvider = Provider<SettingsTabModel>(
  (_) => const SettingsTabModel(),
);

import 'package:core/core.dart';

import 'home_tab.dart';

/// 首页 Shell 业务数据（MVVM-C 的 M 层）。
final class HomeModel {
  const HomeModel();

  String get appName => 'BarrelLock';

  List<HomeTabDescriptor> get tabs => const [
    HomeTabDescriptor(tab: HomeTab.password),
    HomeTabDescriptor(tab: HomeTab.settings),
  ];
}

final homeModelProvider = Provider<HomeModel>((_) => const HomeModel());

import 'package:fast_navigator/fast_navigator.dart';
import 'package:flutter/widgets.dart';

typedef AppRouteBuilder =
    Widget Function(BuildContext context, RouteMatch match);

/// 平台 app 向 [AppRouter] 注入的页面构建器集合。
final class AppRouteBuilders {
  const AppRouteBuilders({
    required this.launchScreen,
    required this.home,
    required this.detail,
    required this.cipherAdd,
    required this.settings,
    required this.dataMigration,
    required this.bluetoothBackup,
    required this.appLock,
    required this.appLockPinSetup,
    required this.clearData,
  });

  final AppRouteBuilder launchScreen;
  final AppRouteBuilder home;
  final AppRouteBuilder detail;
  final AppRouteBuilder cipherAdd;
  final AppRouteBuilder settings;
  final AppRouteBuilder dataMigration;
  final AppRouteBuilder bluetoothBackup;
  final AppRouteBuilder appLock;
  final AppRouteBuilder appLockPinSetup;
  final AppRouteBuilder clearData;
}

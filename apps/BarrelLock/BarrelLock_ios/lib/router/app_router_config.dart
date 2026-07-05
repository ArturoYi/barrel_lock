import 'package:core/core.dart';

import '../pages/detail_page.dart';
import '../pages/home_page.dart';
import '../pages/launch_screen/launch_screen_page.dart';
import '../pages/settings_page.dart';

/// BarrelLock iOS 路由装配：向 [AppRouter] 注入本平台页面 Widget。
///
/// 在 [main] 中、[runApp] 之前调用；路由表定义见 `package:core` 的 [AppRoutes]。
void configureBarrelLockRouter() {
  AppRouter.configure(
    AppRouteBuilders(
      launchScreen: (_, _) => const LaunchScreenPage(),
      home: (_, _) => const HomePage(),
      detail: (_, match) => DetailPage(id: match.parameters.pathParams['id']!),
      settings: (_, _) => const SettingsPage(),
    ),
  );
}

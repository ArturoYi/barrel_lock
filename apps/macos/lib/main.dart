import 'package:barrel_lock_ui/barrel_lock_ui.dart';

import 'router/app_router_config.dart';

Future<void> main() async {
  await runBarrelLockApp(configureRouter: configureBarrelLockRouter);
}

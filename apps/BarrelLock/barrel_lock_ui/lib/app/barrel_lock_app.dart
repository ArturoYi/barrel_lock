import 'package:barrel_lock/barrel_lock.dart';
import 'package:flutter/material.dart';

/// BarrelLock 根 Widget。
class BarrelLockApp extends StatelessWidget {
  const BarrelLockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemedApp.router(routerConfig: AppRouter.routerConfig);
  }
}

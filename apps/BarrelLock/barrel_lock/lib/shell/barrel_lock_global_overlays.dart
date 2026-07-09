import '../features/app_lock/overlay/app_lock_overlay.dart';
import '../features/app_lock/session/app_lock_session_view_model.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// BarrelLock 全局 Overlay 层级 SSOT（自底向上）。
///
/// ```
/// Navigator 页面
///   → FastDialogOverlay
///   → FastToastOverlay (normal)
///   → FastLoadingOverlay
///   → AppLockOverlay（锁屏 / 隐私遮罩）
///   → FastToastElevatedHost（锁屏期间可见的 Toast）
/// ```
final class BarrelLockGlobalOverlays extends StatelessWidget {
  const BarrelLockGlobalOverlays({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FastToastElevatedHost(
      wrapped: AppLockOverlay(
        child: FastLoadingOverlay(
          child: FastToastOverlay(child: FastDialogOverlay(child: child)),
        ),
      ),
    );
  }
}

/// 锁屏会话期间，将 Toast 自动路由到 elevated 层（调用方无需传 [ToastConfig]）。
void configureBarrelLockToastOverlayResolver(WidgetRef ref) {
  FastToast.overlayLayerResolver = (request) {
    final session = ref.read(appLockSessionProvider);
    if (session.isLocked || session.isAuthenticating) {
      return ToastOverlayLayer.elevated;
    }
    return null;
  };
}

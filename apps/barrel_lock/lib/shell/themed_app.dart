import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// BarrelLock 应用主题 + 全局 Overlay 容器。
class ThemedApp extends ConsumerStatefulWidget {
  const ThemedApp.router({
    super.key,
    required RouterConfig<Object> this._routerConfig,
  }) : _home = null;

  const ThemedApp({super.key, required Widget this._home})
    : _routerConfig = null;

  final RouterConfig<Object>? _routerConfig;
  final Widget? _home;

  @override
  ConsumerState<ThemedApp> createState() => _ThemedAppState();
}

class _ThemedAppState extends ConsumerState<ThemedApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FastToast.loadingPauseCheck = () => FastLoading.isShowing;
    FastLoading.visibilityListenable.addListener(_resumeToastAfterLoading);
  }

  @override
  void dispose() {
    FastLoading.visibilityListenable.removeListener(_resumeToastAfterLoading);
    FastToast.overlayLayerResolver = null;
    WidgetsBinding.instance.removeObserver(this);
    disposeBarrelLockLifecycle();
    super.dispose();
  }

  void _resumeToastAfterLoading() {
    if (!FastLoading.isShowing) {
      FastToast.resume();
    }
  }

  @override
  void didChangePlatformBrightness() {
    final mode = ref.read(themeSettingsProvider).mode;
    if (mode == AppThemeMode.system) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(themeSettingsProvider);
    final lightTheme = AppTheme.light(settings.colorScheme);
    final darkTheme = AppTheme.dark(settings.colorScheme);
    final routerConfig = widget._routerConfig;

    final Widget app;
    if (routerConfig != null) {
      app = MaterialApp.router(
        title: 'BarrelLock',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: settings.mode.toFlutter,
        routerConfig: withLoadingRouteGuard(routerConfig),
        builder: (context, child) =>
            _contentOverlayBuilder(context, child, settings.fontScale),
      );
    } else {
      app = MaterialApp(
        title: 'BarrelLock',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: settings.mode.toFlutter,
        home: widget._home,
        builder: (context, child) =>
            _contentOverlayBuilder(context, child, settings.fontScale),
      );
    }

    return AppLockSessionLifecycleBinder(child: app);
  }

  Widget _contentOverlayBuilder(
    BuildContext context,
    Widget? child,
    AppFontScale fontScale,
  ) {
    final content = child ?? const SizedBox.shrink();
    final scaled = MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(fontScale.scaleFactor)),
      child: content,
    );
    return FastToastElevatedHost(
      wrapped: AppLockOverlay(
        child: FastLoadingOverlay(
          child: FastToastOverlay(child: FastDialogOverlay(child: scaled)),
        ),
      ),
    );
  }
}

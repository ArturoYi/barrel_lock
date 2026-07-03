import 'package:fast_loading/fast_loading.dart';
import 'package:fast_toast/fast_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_info.dart';
import '../domain/app_theme_mode.dart';
import 'app_theme.dart';
import 'theme_notifier.dart';

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
    WidgetsBinding.instance.removeObserver(this);
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

    if (routerConfig != null) {
      return MaterialApp.router(
        title: appName,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: settings.mode.toFlutter,
        routerConfig: withLoadingRouteGuard(routerConfig),
        builder: _overlayBuilder,
      );
    }

    return MaterialApp(
      title: appName,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: settings.mode.toFlutter,
      home: widget._home,
      builder: _overlayBuilder,
    );
  }

  Widget _overlayBuilder(BuildContext context, Widget? child) {
    final content = child ?? const SizedBox.shrink();
    return FastLoadingOverlay(child: FastToastOverlay(child: content));
  }
}

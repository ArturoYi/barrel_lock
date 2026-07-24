import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

Locale _resolvedLocale(LocaleSettings localeSettings) {
  return AppL10n.resolveActiveLocale(
    fixedLocale: localeSettings.preference.fixedLocale,
    deviceLocale: WidgetsBinding.instance.platformDispatcher.locale,
  );
}

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
    final localeSettings = ref.watch(localeSettingsProvider);
    final resolvedLocale = _resolvedLocale(localeSettings);
    AppL10nHolder.update(resolvedLocale);
    final lightTheme = AppTheme.light(settings.colorScheme);
    final darkTheme = AppTheme.dark(settings.colorScheme);
    final routerConfig = widget._routerConfig;

    Widget wrapBuilder(BuildContext context, Widget? child) {
      final locale = Localizations.maybeLocaleOf(context) ?? resolvedLocale;
      final direction = locale.languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr;
      return Directionality(
        textDirection: direction,
        child: _contentOverlayBuilder(context, child, settings.fontScale),
      );
    }

    final Widget app;
    if (routerConfig != null) {
      app = MaterialApp.router(
        title: 'BarrelLock',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: settings.mode.toFlutter,
        locale: localeSettings.preference.fixedLocale,
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        localeResolutionCallback: AppL10n.resolveLocale,
        routerConfig: withLoadingRouteGuard(routerConfig),
        builder: wrapBuilder,
      );
    } else {
      app = MaterialApp(
        title: 'BarrelLock',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: settings.mode.toFlutter,
        locale: localeSettings.preference.fixedLocale,
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        localeResolutionCallback: AppL10n.resolveLocale,
        home: widget._home,
        builder: wrapBuilder,
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

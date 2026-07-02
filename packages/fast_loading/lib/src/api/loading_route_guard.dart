import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../core/loading_controller.dart';

/// 在系统返回时优先检查 Loading 状态，必要时阻止路由 pop。
final class LoadingRootBackButtonDispatcher extends RootBackButtonDispatcher {
  @override
  Future<bool> invokeCallback(Future<bool> defaultValue) {
    final controller = LoadingController.instance;
    if (controller.isShowing && controller.config.interceptRouteBack) {
      return SynchronousFuture(true);
    }
    return super.invokeCallback(defaultValue);
  }
}

/// 为 [RouterConfig] 注入 Loading 路由返回拦截。
RouterConfig<T> withLoadingRouteGuard<T>(RouterConfig<T> config) {
  return RouterConfig<T>(
    routerDelegate: config.routerDelegate,
    routeInformationParser: config.routeInformationParser,
    routeInformationProvider: config.routeInformationProvider,
    backButtonDispatcher: LoadingRootBackButtonDispatcher(),
  );
}

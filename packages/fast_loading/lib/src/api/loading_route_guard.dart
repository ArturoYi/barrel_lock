import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../core/loading_controller.dart';

/// 在系统返回时优先检查 Loading 状态，必要时阻止路由 pop。
///
/// 若传入 [delegate]，Loading 未展示时委托给原有 dispatcher。
final class LoadingRootBackButtonDispatcher extends RootBackButtonDispatcher {
  LoadingRootBackButtonDispatcher({BackButtonDispatcher? delegate})
    : _delegate = delegate;

  final BackButtonDispatcher? _delegate;

  @override
  Future<bool> invokeCallback(Future<bool> defaultValue) {
    final controller = LoadingController.instance;
    if (controller.isShowing && controller.config.interceptRouteBack) {
      return SynchronousFuture(true);
    }
    final delegate = _delegate;
    if (delegate != null) {
      return delegate.invokeCallback(defaultValue);
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
    backButtonDispatcher: LoadingRootBackButtonDispatcher(
      delegate: config.backButtonDispatcher,
    ),
  );
}

import 'package:flutter/material.dart';

import '../core/loading_controller.dart';
import '../domain/loading_config.dart';
import '../domain/loading_dismiss_result.dart';

/// 全局 Loading 门面，无需 [BuildContext]。
abstract final class FastLoading {
  static LoadingController get _controller => LoadingController.instance;

  /// 是否正在展示 Loading。
  static bool get isShowing => _controller.isShowing;

  /// 当前引用计数。
  static int get refCount => _controller.refCount;

  /// 展示 Loading；重复调用仅增加引用计数，不叠加 UI。
  static void show({String? message, LoadingConfig? config}) {
    _controller.show(
      config:
          config ?? (message != null ? LoadingConfig(message: message) : null),
    );
  }

  /// 减少引用计数；归零后移除遮罩。
  ///
  /// 传入 [result] 为 success / error 时，先过渡到结果态（自定义或内置 icon + 可选 [message]），
  /// 等待 [resultDisplayDuration]（默认 1s）后再关闭；[LoadingDismissResult.none] 立即关闭。
  static void dismiss({
    LoadingDismissResult result = LoadingDismissResult.none,
    Widget? resultWidget,
    String? message,
    Duration resultDisplayDuration = const Duration(seconds: 1),
  }) {
    _controller.dismiss(
      result: result,
      resultWidget: resultWidget,
      message: message,
      resultDisplayDuration: resultDisplayDuration,
    );
  }

  /// 强制关闭并清零引用计数。
  static void dismissAll() {
    _controller.dismissAll();
  }

  /// 执行异步任务，自动 show / dismiss（finally 保证成对）。
  static Future<T> run<T>(
    Future<T> Function() task, {
    String? message,
    LoadingConfig? config,
  }) {
    return _controller.run(task, message: message, config: config);
  }
}

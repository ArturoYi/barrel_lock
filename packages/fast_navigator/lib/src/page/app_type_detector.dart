import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// App 类型枚举，决定 [PlatformAdaptiveTransition] 解析目标。
enum AppType { material, cupertino, widgets }

/// 探测 Widget 树中的 App 根组件类型。
///
/// 结果会被缓存，避免每次 build 重复 walk 树。
/// 单测可通过 [override] 或 [resetCache] 注入。
abstract final class AppTypeDetector {
  static AppType? _cached;

  static AppType detect(BuildContext context, {AppType? override}) {
    if (override != null) return override;
    return _cached ??= _detectFromTree(context);
  }

  /// 清除缓存（仅供测试）。
  static void resetCache() => _cached = null;

  static AppType _detectFromTree(BuildContext context) {
    if (context.findAncestorWidgetOfExactType<MaterialApp>() != null) {
      return AppType.material;
    }
    if (context.findAncestorWidgetOfExactType<CupertinoApp>() != null) {
      return AppType.cupertino;
    }
    return AppType.widgets;
  }
}

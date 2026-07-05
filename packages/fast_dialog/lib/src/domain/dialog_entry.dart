import 'dart:async';

import 'package:flutter/widgets.dart';

import 'base_dialog.dart';
import 'dialog_config.dart';

/// 弹窗栈内的一条不可变记录。
///
/// 由 [DialogManager] 创建并持有，对应 Overlay 上的一个 [DialogLayer]。
final class DialogEntry<TResult> {
  DialogEntry({
    required this.id,
    required this.builder,
    required this.showConfig,
    required this.completer,
    this.tag,
    this.routeIdentity,
    this.dialog,
  });

  /// 栈内唯一 id（自动生成，如 `dialog_1`）。
  final String id;

  /// 业务去重 tag；可为 null。
  final String? tag;

  /// 业务 UI 构建器。
  final WidgetBuilder builder;

  /// 合并后的展示配置。
  final DialogShowConfig showConfig;

  /// 供 `await FastDialog.show` 接收结果的 Completer。
  final Completer<TResult?> completer;

  /// 弹出时绑定的页面路由标识，用于 [DialogManager.dismissByRoute]。
  final Object? routeIdentity;

  /// 若通过 [BaseDialog] 展示，保留原始实例以读取默认 result。
  final BaseDialog<TResult>? dialog;

  bool get isCompleted => completer.isCompleted;
}

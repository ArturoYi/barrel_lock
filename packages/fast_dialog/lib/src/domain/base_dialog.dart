import 'package:flutter/widgets.dart';

import 'dialog_config.dart';
import 'dialog_mode.dart';

/// 所有弹窗实现的统一约束。
///
/// 业务层继承此类（或使用 [FastDialog.show] 直接传 builder），
/// 框架只负责调度弹出，**不包含任何业务 UI / 文案 / 埋点**。
abstract class BaseDialog<TResult> {
  /// 去重标识；相同 tag 不会重复叠加，仅刷新已有弹窗。
  String? get tag => null;

  /// 模态 / 非模态，默认模态。
  DialogMode get mode => DialogMode.modal;

  /// 单次展示配置，可与全局 [DialogConfig.defaultShowConfig] 合并。
  DialogShowConfig get showConfig => const DialogShowConfig();

  /// 业务层完全自定义的弹窗 UI。
  Widget build(BuildContext context);

  /// 关闭时默认回传的结果（可被 dismiss(result:) 覆盖）。
  TResult? get result => null;
}

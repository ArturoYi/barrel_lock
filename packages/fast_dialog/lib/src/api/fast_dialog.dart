import 'package:flutter/widgets.dart';

import '../core/dialog_manager.dart';
import '../domain/base_dialog.dart';
import '../domain/dialog_config.dart';

/// 全局弹窗门面：业务层通过静态方法调用，无需 [BuildContext]。
///
/// 所有方法均委托给单例 [DialogManager]，保证弹窗栈 SSOT。
///
/// ## 典型用法
///
/// ```dart
/// final ok = await FastDialog.show<bool>(
///   tag: 'confirm',
///   builder: (ctx) => MyDialog(
///     onOk: () => FastDialog.dismiss(result: true),
///   ),
/// );
/// ```
abstract final class FastDialog {
  static DialogManager get _manager => DialogManager.instance;

  /// 注入全局默认配置（通常由 [FastDialogOverlay] 在挂载时调用）。
  static void configure(DialogConfig config) => _manager.configure(config);

  /// 展示自定义 UI 弹窗，返回 [Future] 供 await 接收按钮结果。
  ///
  /// [tag] 相同时复用已有弹窗并刷新内容，不会重复叠加。
  static Future<T?> show<T>({
    required WidgetBuilder builder,
    DialogShowConfig? showConfig,
    String? tag,
    BaseDialog<T>? dialog,
  }) {
    return _manager.show<T>(
      builder: builder,
      showConfig: showConfig,
      tag: tag,
      dialog: dialog,
    );
  }

  /// 展示实现了 [BaseDialog] 约束的弹窗实例。
  static Future<T?> showDialog<T>(BaseDialog<T> dialog) =>
      _manager.showDialog<T>(dialog);

  /// 关闭栈顶弹窗，或通过 [id] / [tag] 指定目标。
  static void dismiss({String? id, String? tag, dynamic result}) =>
      _manager.dismiss(id: id, tag: tag, result: result);

  /// 关闭全部弹窗（如登出、切换账号场景）。
  static void dismissAll({dynamic result}) =>
      _manager.dismissAll(result: result);

  /// 是否有弹窗正在展示。
  static bool get isShowing => _manager.isShowing;

  /// 手动绑定当前路由标识。
  ///
  /// 若已通过 [DialogRouteObserver.forManager] 注入 Navigator，通常无需调用。
  static void bindRoute(Object? routeIdentity) =>
      _manager.bindRoute(routeIdentity);
}

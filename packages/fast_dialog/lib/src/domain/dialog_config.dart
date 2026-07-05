import 'package:flutter/widgets.dart';

import 'dialog_animation.dart';
import 'dialog_mask.dart';
import 'dialog_mode.dart';

/// 单次弹窗展示配置。
///
/// 可在 [FastDialog.show] 传入，或与 [DialogConfig.defaultShowConfig] 合并。
/// 使用 [copyWith] 基于全局配置做局部覆盖。
final class DialogShowConfig {
  const DialogShowConfig({
    this.mode = DialogMode.modal,
    this.mask = const DialogMaskColor(),
    this.maskDismissible = true,
    this.animation = const DialogAnimationSpec(),
    this.ignoreSafeArea = true,
    this.usePenetrate = false,
    this.zIndex = 0,
    this.enableDragDismiss = false,
    this.dragDismissThreshold = 120,
    this.scrollable = true,
    this.onShow,
    this.onDismiss,
  });

  /// 模态 / 非模态。
  final DialogMode mode;

  /// 遮罩样式（纯色 / 模糊 / 无遮罩）。
  final DialogMask mask;

  /// 点击遮罩是否关闭（仅模态且非穿透时生效）。
  final bool maskDismissible;

  /// 入场/退场动画规格。
  final DialogAnimationSpec animation;

  /// 为 true 时弹窗内容不避让安全区（如全屏 BottomSheet）。
  final bool ignoreSafeArea;

  /// 为 true 时遮罩可见但点击穿透到底层（模态专用）。
  final bool usePenetrate;

  /// 多弹窗叠加时的层级，数值越大越靠上。
  final int zIndex;

  /// 是否启用下拉关闭（通常配合 slideFromBottom）。
  final bool enableDragDismiss;

  /// 下拉超过此像素阈值触发关闭。
  final double dragDismissThreshold;

  /// 内容超长时是否包裹 [SingleChildScrollView]。
  final bool scrollable;

  /// 入场动画完全结束后回调。
  final VoidCallback? onShow;

  /// 退场动画完全结束后回调。
  final VoidCallback? onDismiss;

  DialogShowConfig copyWith({
    DialogMode? mode,
    DialogMask? mask,
    bool? maskDismissible,
    DialogAnimationSpec? animation,
    bool? ignoreSafeArea,
    bool? usePenetrate,
    int? zIndex,
    bool? enableDragDismiss,
    double? dragDismissThreshold,
    bool? scrollable,
    VoidCallback? onShow,
    VoidCallback? onDismiss,
  }) {
    return DialogShowConfig(
      mode: mode ?? this.mode,
      mask: mask ?? this.mask,
      maskDismissible: maskDismissible ?? this.maskDismissible,
      animation: animation ?? this.animation,
      ignoreSafeArea: ignoreSafeArea ?? this.ignoreSafeArea,
      usePenetrate: usePenetrate ?? this.usePenetrate,
      zIndex: zIndex ?? this.zIndex,
      enableDragDismiss: enableDragDismiss ?? this.enableDragDismiss,
      dragDismissThreshold: dragDismissThreshold ?? this.dragDismissThreshold,
      scrollable: scrollable ?? this.scrollable,
      onShow: onShow ?? this.onShow,
      onDismiss: onDismiss ?? this.onDismiss,
    );
  }
}

/// 全局初始化配置，在 [FastDialogOverlay] 挂载时注入。
final class DialogConfig {
  const DialogConfig({this.defaultShowConfig = const DialogShowConfig()});

  /// 所有 show 调用的默认配置基线。
  final DialogShowConfig defaultShowConfig;
}

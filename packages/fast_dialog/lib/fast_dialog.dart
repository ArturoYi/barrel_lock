/// fast_dialog — 全局 Dialog 弹窗栈框架。
///
/// 仅负责 Dialog 的弹出调度，UI 完全由业务层通过 [WidgetBuilder] / [BaseDialog] 注入。
/// 不包含 Loading、Toast 等非 Dialog 弹出层。
library;

export 'src/api/dialog_route_guard.dart';
export 'src/api/fast_dialog.dart';
export 'src/api/fast_dialog_overlay.dart';
export 'src/domain/base_dialog.dart';
export 'src/domain/dialog_animation.dart';
export 'src/domain/dialog_config.dart';
export 'src/domain/dialog_entry.dart';
export 'src/domain/dialog_mask.dart';
export 'src/domain/dialog_mode.dart';
export 'src/presentation/dialog_animator.dart';
export 'src/presentation/dialog_barrier.dart';
export 'src/presentation/dialog_shell.dart';

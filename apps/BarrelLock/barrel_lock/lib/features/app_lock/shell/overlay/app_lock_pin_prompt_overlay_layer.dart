import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 为全局 PIN 输入面板提供 [Overlay] 祖先（挂在 [MaterialApp.builder] 外层）。
///
/// [EditableText] 创建选区浮层时需要 Overlay；直接放在 Stack 里会触发
/// `debugCheckHasOverlay`。
///
/// ## 自定义实现指引
///
/// ### 数据源（Riverpod）
///
/// ```dart
/// import '../../runtime_auth/app_lock_pin_prompt_view_model.dart';
/// ```
///
/// - **Provider**：[`appLockPinPromptProvider`]
///   - 类型：`NotifierProvider<AppLockPinPromptViewModel, AppLockPinPromptState?>`
///   - `null` → 隐藏 PIN 遮罩；非 `null` → 显示并渲染输入 UI
/// - **监听方式**：
///   - `ref.listenManual(appLockPinPromptProvider, ...)` 在 `initState` 中订阅变化
///   - 首帧用 `ref.read(appLockPinPromptProvider)` 同步初始状态
///   - 状态变更后通过 `addPostFrameCallback` 延迟同步，避免 build 期间插入 OverlayEntry
///
/// ### 状态字段（[`AppLockPinPromptState`]）
///
/// | 字段 | 类型 | 用途 |
/// |------|------|------|
/// | `reason` | `IdentityAuthReason` | 验证场景；标题/副文案可用 `reason.defaultMessage` |
/// | `errorMessage` | `String?` | 校验失败提示；非空时展示错误文案 |
/// | `attempt` | `int` | 每次 `requestPin` 递增；用作 `Key` 重置输入框 |
/// | `obscurePin` | `bool` | 是否遮蔽 PIN 明文 |
/// | `isSubmitting` | `bool` | 提交中；应禁用输入与按钮 |
///
/// ### 用户交互（[`AppLockPinPromptViewModel`] notifier）
///
/// ```dart
/// final vm = ref.read(appLockPinPromptProvider.notifier);
/// vm.submitPin(pin);   // 确认；空字符串会写入 errorMessage
/// vm.cancel();         // 取消；返回 null 给等待方
/// vm.toggleObscure();  // 切换明文/密文
/// vm.dismiss();        // 关闭遮罩（验证成功时由 Session VM 调用，View 一般不需主动调用）
/// ```
///
/// ### Overlay 层实现要点
///
/// - **`GlobalKey<OverlayState>`**：挂到根 `Overlay` 上，通过 `currentState` 插入/移除 `OverlayEntry`
/// - **`OverlayEntry`**：`pinPrompt != null` 时 insert；`null` 时 remove + dispose
/// - **面板内容**：可自建 UI，或复用 [`AppLockPinPromptPanel`]（传入 `state: pinPrompt`）
/// - **`FocusScope`**：包裹 PIN 面板，便于键盘与焦点管理
/// - **生命周期**：`dispose` 时关闭 `ProviderSubscription`、移除并 dispose `OverlayEntry`
///
/// ### 挂载位置
///
/// 由 [`AppLockOverlay`] 放入 `Stack` 最上层，与 [`appLockSessionProvider`] 的锁屏遮罩并列。
final class AppLockPinPromptOverlayLayer extends ConsumerStatefulWidget {
  const AppLockPinPromptOverlayLayer({super.key});

  @override
  ConsumerState<AppLockPinPromptOverlayLayer> createState() =>
      _AppLockPinPromptOverlayLayerState();
}

class _AppLockPinPromptOverlayLayerState
    extends ConsumerState<AppLockPinPromptOverlayLayer> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(child: Text("2323234"));
  }
}

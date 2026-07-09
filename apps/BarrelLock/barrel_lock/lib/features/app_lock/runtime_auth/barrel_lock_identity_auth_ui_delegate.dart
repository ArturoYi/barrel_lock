/// 运行时身份验证 UI 桥接层（`runtime_auth/` 子域）。
///
/// ## 子域职责
///
/// 本目录只处理**应用已运行期间**的解锁 PIN 交互，与以下子域区分：
///
/// | 子域 | 场景 |
/// |------|------|
/// | [enable_setup](../enable_setup/) | 首次开启保护时设置 PIN |
/// | [pin_manage](../pin_manage/) | 设置页内的 PIN 日常管理（修改 / 清除） |
/// | **runtime_auth**（本目录） | 冷启动 / 后台恢复等**运行时解锁** |
/// | [overlay](../overlay/) | 全局 PIN / 锁屏遮罩的 View 实现 |
///
/// core 的 [AppIdentityAuth] 只负责生物识别与 PIN 哈希校验，不持有 Widget；
/// 本目录通过 [IdentityAuthUiDelegate] 把「弹出 PIN 输入 UI」接到
/// [AppLockPinPromptViewModel]，再由 [overlay] 层渲染遮罩。
///
/// ## 调用链
///
/// ```
/// AppLockSessionViewModel._authenticate
///   → AppLockAuthService.authenticateForAppLock
///     → AppIdentityAuth.authenticate (core)
///       → BarrelLockIdentityAuthUiDelegate.promptForAppPin  ← 本文件
///         → AppLockPinPromptViewModel.requestPin
///           → overlay 监听 appLockPinPromptProvider 并展示 PIN 面板
/// ```
///
/// 验证失败后的 PIN 重试循环由 [AppLockSessionViewModel] 直接调用
/// [AppLockPinPromptViewModel.requestPin]，同样走 overlay，不经过本委托。
library;

import 'package:core/core.dart';

import 'app_lock_pin_prompt_view_model.dart';

/// BarrelLock 默认 [IdentityAuthUiDelegate] 实现。
///
/// 将 core 身份验证流程中的 UI 回调映射到全局 PIN 遮罩 ViewModel：
///
/// - [promptForAppPin] → 挂起并等待 [AppLockPinPromptViewModel.requestPin]
/// - [onBiometricUnavailable] → Toast 引导用户使用应用内密码
///
/// 注入点：[identityAuthUiDelegateProvider]（定义于 [AppLockAuthService] 旁）。
/// 各平台可在 [ProviderScope] 中 override 以替换交互方式（如改用全屏路由页）。
final class BarrelLockIdentityAuthUiDelegate implements IdentityAuthUiDelegate {
  BarrelLockIdentityAuthUiDelegate(this._ref);

  final Ref _ref;

  @override
  Future<String?> promptForAppPin({required IdentityAuthReason reason}) {
    return _ref.read(appLockPinPromptProvider.notifier).requestPin(reason);
  }

  @override
  Future<void> onBiometricUnavailable({
    required IdentityAuthReason reason,
  }) async {
    FastToast.show('生物识别不可用，请使用应用内密码');
  }
}

import 'package:barrel_lock/barrel_lock.dart';
import 'package:flutter/material.dart';

import 'pages/hint/app_lock_enable_setup_portrait_hint_page.dart';
import 'pages/pin/app_lock_enable_setup_portrait_pin_page.dart';

/// 竖屏开启验证 Panel 的布局壳（MVVM-C 的 V 层）。
///
/// 职责：
/// - 提供全屏 [Scaffold] 与随步骤变化的 [AppBar] 标题
/// - 托管 [PageController] 驱动的两步 [PageView]（PIN → 提示语）
/// - 将 Host 传入的状态与回调转发给各 [Page] 子组件
///
/// 不包含业务逻辑；PIN 缓冲、步骤切换、提交均由 [AppLockEnableSetupHost] 处理。
final class AppLockEnableSetupPortraitLayout extends StatelessWidget {
  const AppLockEnableSetupPortraitLayout({
    super.key,
    required this.state,
    required this.pageController,
    required this.pinBuffer,
    required this.hintController,
    required this.hintFocusNode,
    required this.onDigitPressed,
    required this.onDeletePressed,
    required this.onContinueToHint,
    required this.onSubmitSetup,
    required this.onBack,
    required this.onToggleObscurePin,
  });

  /// ViewModel 输出的流程状态。
  final AppLockEnableSetupState state;

  /// PageView 控制器，由 Host 持有并与 [AppLockEnableSetupStep] 同步。
  final PageController pageController;

  /// Host 维护的主密码缓冲（自定义键盘写入，非 TextField）。
  ///
  /// 长度范围 0–[AppLockPinPolicy.length]；进入提示语步骤后仍保留，
  /// 以便从提示语回退 PIN 时无需重新输入。
  final String pinBuffer;

  /// 提示语步骤的文本输入控制器，生命周期由 Host 创建与销毁。
  final TextEditingController hintController;

  /// 提示语输入框焦点节点；Host 在切换到 hint 步骤后自动请求焦点。
  final FocusNode hintFocusNode;

  /// 数字键（0–9）按下：向 [pinBuffer] 追加一位数字。
  ///
  /// 提交中或已满位时 Host 端会忽略输入。
  final ValueChanged<int> onDigitPressed;

  /// 退格键按下：删除 [pinBuffer] 末位。
  ///
  /// 提交中或缓冲为空时 Host 端会忽略。
  final VoidCallback onDeletePressed;

  /// 「下一步」或外接键盘 Enter：校验 PIN 并通知 ViewModel 进入提示语步骤。
  final VoidCallback onContinueToHint;

  /// 提示语步骤提交：校验提示语并落盘 PIN，开启应用保护。
  final VoidCallback onSubmitSetup;

  /// 导航回退回调，行为随当前步骤变化：
  ///
  /// - PIN 步骤（AppBar 返回 / 外接键盘 Esc）：取消整个流程
  /// - 提示语步骤（AppBar 返回 / 「上一步」）：回退至 PIN 步骤，保留已输入 PIN
  ///
  /// 提交中（[AppLockEnableSetupState.isBusy]）时 AppBar 侧会禁用。
  final VoidCallback onBack;

  /// 切换 PIN 展示框的明文/密文显示。
  final VoidCallback onToggleObscurePin;

  @override
  Widget build(BuildContext context) {
    // AppBar 标题随当前步骤变化
    final title = switch (state.step) {
      AppLockEnableSetupStep.pin => '设置备用密码',
      AppLockEnableSetupStep.hint => '设置提示语',
    };

    return Scaffold(
      appBar: AppBar(
        // 提交中禁用返回，防止中断落盘
        leading: BackButton(onPressed: state.isBusy ? null : onBack),
        title: Text(title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 8,
            bottom: 24,
          ),
          child: PageView(
            controller: pageController,
            // 禁止手势滑动；步骤切换仅由 ViewModel step 驱动
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // 第 0 页：PIN 设置
              AppLockEnableSetupPortraitPinPage(
                state: state,
                pinBuffer: pinBuffer,
                onDigitPressed: onDigitPressed,
                onDeletePressed: onDeletePressed,
                onContinueToHint: onContinueToHint,
                onBack: onBack,
                onToggleObscurePin: onToggleObscurePin,
              ),
              // 第 1 页：提示语设置
              AppLockEnableSetupPortraitHintPage(
                state: state,
                hintController: hintController,
                hintFocusNode: hintFocusNode,
                onSubmit: onSubmitSetup,
                onBack: onBack,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

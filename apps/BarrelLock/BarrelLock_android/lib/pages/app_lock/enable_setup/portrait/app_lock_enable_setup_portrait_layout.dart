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
    required this.onClearPressed,
    required this.onContinueToHint,
    required this.onSubmitSetup,
    required this.onBackToPinStep,
    required this.onCancel,
    required this.onBack,
    required this.onToggleObscurePin,
  });

  /// ViewModel 输出的流程状态。
  final AppLockEnableSetupState state;

  /// PageView 控制器，由 Host 持有并与 [AppLockEnableSetupStep] 同步。
  final PageController pageController;

  final String pinBuffer;
  final TextEditingController hintController;
  final FocusNode hintFocusNode;
  final ValueChanged<int> onDigitPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onClearPressed;
  final VoidCallback onContinueToHint;
  final VoidCallback onSubmitSetup;
  final VoidCallback onBackToPinStep;
  final VoidCallback onCancel;

  /// AppBar 返回按钮回调：提示语步骤回退 PIN，PIN 步骤取消流程。
  final VoidCallback onBack;
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
                onClearPressed: onClearPressed,
                onContinueToHint: onContinueToHint,
                onCancel: onCancel,
                onToggleObscurePin: onToggleObscurePin,
              ),
              // 第 1 页：提示语设置
              AppLockEnableSetupPortraitHintPage(
                state: state,
                hintController: hintController,
                hintFocusNode: hintFocusNode,
                onSubmit: onSubmitSetup,
                onBack: onBackToPinStep,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:barrel_lock/barrel_lock.dart';
import 'package:flutter/material.dart';

import 'pages/hint/app_lock_enable_setup_landscape_hint_page.dart';
import 'pages/pin/app_lock_enable_setup_landscape_pin_page.dart';

/// 横屏开启验证 Panel 的布局壳（MVVM-C 的 V 层）。
///
/// 与 [AppLockEnableSetupPortraitLayout] 结构相同，额外通过
/// [ConstrainedBox] 限制内容最大宽度，避免超宽屏下 Page 内容过度拉伸。
final class AppLockEnableSetupLandscapeLayout extends StatelessWidget {
  const AppLockEnableSetupLandscapeLayout({
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

  final AppLockEnableSetupState state;
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
  final VoidCallback onBack;
  final VoidCallback onToggleObscurePin;

  /// PageView 内容区最大宽度（含左右分栏 PIN / 提示语页）。
  static const _inputMaxWidth = 720.0;

  @override
  Widget build(BuildContext context) {
    final title = switch (state.step) {
      AppLockEnableSetupStep.pin => '设置备用密码',
      AppLockEnableSetupStep.hint => '设置提示语',
    };

    return Scaffold(
      appBar: AppBar(
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
          // 横屏内容水平居中，并限制最大宽度
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _inputMaxWidth),
              child: PageView(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  AppLockEnableSetupLandscapePinPage(
                    state: state,
                    pinBuffer: pinBuffer,
                    onDigitPressed: onDigitPressed,
                    onDeletePressed: onDeletePressed,
                    onClearPressed: onClearPressed,
                    onContinueToHint: onContinueToHint,
                    onCancel: onCancel,
                    onToggleObscurePin: onToggleObscurePin,
                  ),
                  AppLockEnableSetupLandscapeHintPage(
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
        ),
      ),
    );
  }
}

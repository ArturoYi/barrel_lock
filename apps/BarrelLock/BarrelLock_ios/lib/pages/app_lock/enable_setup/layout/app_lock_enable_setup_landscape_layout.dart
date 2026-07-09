import 'package:barrel_lock/barrel_lock.dart';
import 'package:flutter/material.dart';

/// 横屏全屏：AppBar + PageView（PIN / 提示语两步）。
final class AppLockEnableSetupLandscapeLayout extends StatelessWidget {
  const AppLockEnableSetupLandscapeLayout({
    super.key,
    required this.state,
    required this.pageController,
    required this.pinPage,
    required this.hintPage,
    required this.onBack,
  });

  final AppLockEnableSetupState state;
  final PageController pageController;
  final Widget pinPage;
  final Widget hintPage;
  final VoidCallback onBack;

  static const _inputMaxWidth = 360.0;

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
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 8,
            bottom: 24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _inputMaxWidth),
              child: PageView(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [pinPage, hintPage],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

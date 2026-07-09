import 'package:barrel_lock/barrel_lock.dart';
import 'package:flutter/material.dart';

/// 竖屏全屏：AppBar + PageView（PIN / 提示语两步）。
final class AppLockEnableSetupPortraitLayout extends StatelessWidget {
  const AppLockEnableSetupPortraitLayout({
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
          child: PageView(
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [pinPage, hintPage],
          ),
        ),
      ),
    );
  }
}

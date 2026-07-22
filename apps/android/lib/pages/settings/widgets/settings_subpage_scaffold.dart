import 'package:flutter/material.dart';

/// 设置子页通用脚手架：统一 AppBar、返回与 SafeArea。
///
/// 子页 View 只负责 body 内容；返回事件交给各 feature 的 ViewModel.onPop。
class SettingsSubpageScaffold extends StatelessWidget {
  const SettingsSubpageScaffold({
    super.key,
    required this.title,
    required this.onBack,
    required this.body,
    this.floatingActionButton,
  });

  final String title;
  final VoidCallback onBack;
  final Widget body;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: onBack),
        title: Text(title),
      ),
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
    );
  }
}

import 'package:barrel_lock/barrel_lock.dart';
import 'package:barrel_lock_ui/barrel_lock_ui.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 语言设置页。
class LanguageSettingsPage extends ConsumerWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(languageSettingsViewModelProvider);
    final viewModel = ref.read(languageSettingsViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: viewModel.onPop),
        title: Text(context.l10n.settings_language),
      ),
      body: LanguageSettingsBody(
        selected: selected,
        onSelected: viewModel.select,
      ),
    );
  }
}

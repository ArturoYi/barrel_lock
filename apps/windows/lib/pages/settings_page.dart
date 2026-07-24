import 'package:barrel_lock/barrel_lock.dart';
import 'package:barrel_lock_ui/barrel_lock_ui.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 设置页（MVVM-C 的 V 层）。
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(settingsViewModelProvider.notifier);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings_title)),
      body: ListView(
        children: [
          const SizedBox(height: 24),
          LanguageSettingsEntryTile(
            onTap: () => AppRouter.push(AppRoutes.languageSettings.path),
          ),
          const ThemeSettingSection(),
          const SizedBox(height: 32),
          Center(
            child: FilledButton(
              onPressed: viewModel.onPop,
              child: Text(l10n.common_back),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:barrel_lock/barrel_lock.dart';
import 'package:barrel_lock_ui/barrel_lock_ui.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 首页「设置」Tab（桌面端占位 + 外观设置）。
class SettingsTabPage extends ConsumerWidget {
  const SettingsTabPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        LanguageSettingsEntryTile(
          onTap: () => AppRouter.push(AppRoutes.languageSettings.path),
        ),
        const ThemeSettingSection(),
      ],
    );
  }
}

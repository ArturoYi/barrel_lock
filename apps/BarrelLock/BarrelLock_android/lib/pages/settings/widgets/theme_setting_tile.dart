import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'settings_section_card.dart';

/// 外观分组内联 UI：主题模式 + 主题色（竖屏直接展示 / 横屏 Detail 面板）。
class ThemeSettingTile extends ConsumerWidget {
  const ThemeSettingTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(themeSettingsProvider);
    final notifier = ref.read(themeSettingsProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SettingsSubsectionTitle(title: '主题模式'),
          const SizedBox(height: 12),
          SegmentedButton<AppThemeMode>(
            segments: const [
              ButtonSegment(value: AppThemeMode.system, label: Text('跟随系统')),
              ButtonSegment(value: AppThemeMode.light, label: Text('浅色')),
              ButtonSegment(value: AppThemeMode.dark, label: Text('深色')),
            ],
            selected: {settings.mode},
            onSelectionChanged: (selected) {
              notifier.setMode(selected.first);
            },
          ),
          const SizedBox(height: 24),
          const SettingsSubsectionTitle(title: '主题色'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final scheme in AppColorScheme.values)
                ChoiceChip(
                  label: Text(scheme.displayName),
                  selected: settings.colorScheme == scheme,
                  avatar: CircleAvatar(backgroundColor: scheme.seedColor),
                  onSelected: (_) => notifier.setColorScheme(scheme),
                ),
            ],
          ),
          const SizedBox(height: 24),
          const SettingsSubsectionTitle(title: '字体大小'),
          const SizedBox(height: 12),
          SegmentedButton<AppFontScale>(
            segments: [
              for (final scale in AppFontScale.values)
                ButtonSegment(value: scale, label: Text(scale.displayName)),
            ],
            selected: {settings.fontScale},
            onSelectionChanged: (selected) {
              notifier.setFontScale(selected.first);
            },
          ),
        ],
      ),
    );
  }
}

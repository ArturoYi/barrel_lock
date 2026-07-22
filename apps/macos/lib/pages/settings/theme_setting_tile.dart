import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 主题设置 UI 组件。
class ThemeSettingTile extends ConsumerWidget {
  const ThemeSettingTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(themeSettingsProvider);
    final notifier = ref.read(themeSettingsProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('主题模式', style: context.textTheme.titleMedium),
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
          Text('主题色', style: context.textTheme.titleMedium),
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
          Text('字体大小', style: context.textTheme.titleMedium),
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

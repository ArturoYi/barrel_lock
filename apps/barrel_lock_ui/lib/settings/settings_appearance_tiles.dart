import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 卡片内小标题（如「主题模式」）。
class SettingsSubsectionTitle extends StatelessWidget {
  const SettingsSubsectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Text(
      title,
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }
}

/// 圆角卡片包裹的 [ThemeSettingTile]，用于桌面端设置 Tab 等无外层卡片的场景。
class ThemeSettingSection extends StatelessWidget {
  const ThemeSettingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Material(
        color: colorScheme.surfaceContainerLow,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: const ThemeSettingTile(),
      ),
    );
  }
}

/// 外观分组内联 UI：主题模式 + 主题色 + 字体大小。
class ThemeSettingTile extends ConsumerWidget {
  const ThemeSettingTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(themeSettingsProvider);
    final notifier = ref.read(themeSettingsProvider.notifier);
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsSubsectionTitle(title: l10n.settings_themeMode),
          const SizedBox(height: 10),
          _ThemeModePicker(
            selected: settings.mode,
            onSelected: notifier.setMode,
            l10n: l10n,
          ),
          const SizedBox(height: 20),
          SettingsSubsectionTitle(title: l10n.settings_accentColor),
          const SizedBox(height: 10),
          _AccentColorPicker(
            selected: settings.colorScheme,
            onSelected: notifier.setColorScheme,
            l10n: l10n,
          ),
          const SizedBox(height: 20),
          SettingsSubsectionTitle(title: l10n.settings_fontSize),
          const SizedBox(height: 10),
          _FontScalePicker(
            selected: settings.fontScale,
            onSelected: notifier.setFontScale,
            l10n: l10n,
          ),
        ],
      ),
    );
  }
}

class _ThemeModePicker extends StatelessWidget {
  const _ThemeModePicker({
    required this.selected,
    required this.onSelected,
    required this.l10n,
  });

  final AppThemeMode selected;
  final ValueChanged<AppThemeMode> onSelected;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return _SegmentedIconBar<AppThemeMode>(
      options: [
        _SegmentOption(
          value: AppThemeMode.system,
          icon: Icons.brightness_auto_rounded,
          label: l10n.settings_themeFollowSystem,
        ),
        _SegmentOption(
          value: AppThemeMode.light,
          icon: Icons.light_mode_rounded,
          label: l10n.settings_themeLight,
        ),
        _SegmentOption(
          value: AppThemeMode.dark,
          icon: Icons.dark_mode_rounded,
          label: l10n.settings_themeDark,
        ),
      ],
      selected: selected,
      onSelected: onSelected,
    );
  }
}

class _AccentColorPicker extends StatelessWidget {
  const _AccentColorPicker({
    required this.selected,
    required this.onSelected,
    required this.l10n,
  });

  final AppColorScheme selected;
  final ValueChanged<AppColorScheme> onSelected;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        const swatchOuter = 48.0;
        final count = AppColorScheme.values.length;
        final maxWidth = constraints.maxWidth;
        final fitsInRow =
            maxWidth >= count * swatchOuter + (count - 1) * spacing;

        final swatches = [
          for (final scheme in AppColorScheme.values)
            _AccentColorSwatch(
              color: scheme.seedColor,
              label: _colorSchemeLabel(l10n, scheme),
              selected: selected == scheme,
              onTap: () => onSelected(scheme),
            ),
        ];

        if (fitsInRow) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: swatches,
          );
        }

        return Wrap(
          alignment: WrapAlignment.center,
          spacing: spacing,
          runSpacing: spacing,
          children: swatches,
        );
      },
    );
  }
}

class _AccentColorSwatch extends StatelessWidget {
  const _AccentColorSwatch({
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final checkColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black87;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant.withValues(alpha: 0.6),
                width: selected ? 2.5 : 1,
              ),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: selected ? 34 : 36,
              height: selected ? 34 : 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.45),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: selected
                  ? Icon(Icons.check_rounded, size: 20, color: checkColor)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _FontScalePicker extends StatelessWidget {
  const _FontScalePicker({
    required this.selected,
    required this.onSelected,
    required this.l10n,
  });

  final AppFontScale selected;
  final ValueChanged<AppFontScale> onSelected;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return _SegmentedIconBar<AppFontScale>(
      options: [
        for (final scale in AppFontScale.values)
          _SegmentOption(
            value: scale,
            icon: null,
            label: _fontScaleLabel(l10n, scale),
            previewText: 'Aa',
            previewFontSize: _fontPreviewSize(scale),
          ),
      ],
      selected: selected,
      onSelected: onSelected,
    );
  }
}

double _fontPreviewSize(AppFontScale scale) => switch (scale) {
  AppFontScale.small => 14,
  AppFontScale.standard => 16,
  AppFontScale.large => 19,
  AppFontScale.extraLarge => 22,
};

class _SegmentOption<T> {
  const _SegmentOption({
    required this.value,
    required this.label,
    this.icon,
    this.previewText,
    this.previewFontSize,
  });

  final T value;
  final String label;
  final IconData? icon;
  final String? previewText;
  final double? previewFontSize;
}

class _SegmentedIconBar<T> extends StatelessWidget {
  const _SegmentedIconBar({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<_SegmentOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            for (var i = 0; i < options.length; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              Expanded(
                child: _SegmentTile<T>(
                  option: options[i],
                  selected: options[i].value == selected,
                  onTap: () => onSelected(options[i].value),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SegmentTile<T> extends StatelessWidget {
  const _SegmentTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _SegmentOption<T> option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final foreground = selected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: option.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            decoration: BoxDecoration(
              color: selected ? colorScheme.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (option.icon != null)
                  Icon(option.icon, size: 22, color: foreground)
                else
                  Text(
                    option.previewText ?? '',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: option.previewFontSize,
                      fontWeight: FontWeight.w600,
                      color: foreground,
                      height: 1.1,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  option.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: selected
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _fontScaleLabel(AppLocalizations l10n, AppFontScale scale) {
  return switch (scale) {
    AppFontScale.small => l10n.settings_fontScale_small,
    AppFontScale.standard => l10n.settings_fontScale_standard,
    AppFontScale.large => l10n.settings_fontScale_large,
    AppFontScale.extraLarge => l10n.settings_fontScale_extraLarge,
  };
}

String _colorSchemeLabel(AppLocalizations l10n, AppColorScheme scheme) {
  return switch (scheme) {
    AppColorScheme.deepPurple => l10n.settings_colorScheme_deepPurple,
    AppColorScheme.blue => l10n.settings_colorScheme_blue,
    AppColorScheme.green => l10n.settings_colorScheme_green,
    AppColorScheme.orange => l10n.settings_colorScheme_orange,
    AppColorScheme.teal => l10n.settings_colorScheme_teal,
  };
}

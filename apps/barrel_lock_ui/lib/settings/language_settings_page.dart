import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 语言设置页主体：五档单选列表。
class LanguageSettingsBody extends ConsumerWidget {
  const LanguageSettingsBody({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final AppLocalePreference selected;
  final ValueChanged<AppLocalePreference> onSelected;

  static const List<AppLocalePreference> options = [
    AppLocalePreference.system,
    AppLocalePreference.zhHans,
    AppLocalePreference.zhHant,
    AppLocalePreference.en,
    AppLocalePreference.ar,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return ListView(
      children: [
        for (final preference in options)
          RadioListTile<AppLocalePreference>(
            value: preference,
            groupValue: selected,
            onChanged: (value) {
              if (value != null) onSelected(value);
            },
            title: Text(_titleFor(preference, l10n)),
            subtitle: preference == AppLocalePreference.system
                ? Text(l10n.settings_language_follow_system)
                : null,
          ),
      ],
    );
  }

  String _titleFor(AppLocalePreference preference, AppLocalizations l10n) {
    return switch (preference) {
      AppLocalePreference.system => l10n.locale_follow_system,
      AppLocalePreference.zhHans => l10n.settings_language_summary_zh_hans,
      AppLocalePreference.zhHant => l10n.settings_language_summary_zh_hant,
      AppLocalePreference.en => l10n.settings_language_summary_en,
      AppLocalePreference.ar => l10n.settings_language_summary_ar,
    };
  }
}

/// 设置列表中的语言入口（桌面 / 独立设置页）。
class LanguageSettingsEntryTile extends ConsumerWidget {
  const LanguageSettingsEntryTile({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preference = ref.watch(localeSettingsProvider).preference;
    final l10n = context.l10n;

    return ListTile(
      leading: const Icon(Icons.language_outlined),
      title: Text(l10n.settings_language),
      subtitle: Text(_summaryFor(l10n, preference)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  String _summaryFor(AppLocalizations l10n, AppLocalePreference preference) {
    return switch (preference) {
      AppLocalePreference.system => l10n.settings_language_summary_system,
      AppLocalePreference.zhHans => l10n.settings_language_summary_zh_hans,
      AppLocalePreference.zhHant => l10n.settings_language_summary_zh_hant,
      AppLocalePreference.en => l10n.settings_language_summary_en,
      AppLocalePreference.ar => l10n.settings_language_summary_ar,
    };
  }
}

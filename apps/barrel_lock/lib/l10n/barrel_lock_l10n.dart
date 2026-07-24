import 'package:core/core.dart';

import '../features/home/home_tab.dart';
import '../features/home/tabs/settings/settings_section.dart';

extension BarrelLockL10n on AppLocalizations {
  String homeTabLabel(HomeTab tab) => switch (tab) {
    HomeTab.password => tab_password,
    HomeTab.settings => tab_settings,
  };

  String settingsSectionTitle(SettingsSectionKind kind) => switch (kind) {
    SettingsSectionKind.general => settings_section_general,
    SettingsSectionKind.theme => settings_section_appearance,
    SettingsSectionKind.data => settings_section_data,
    SettingsSectionKind.security => settings_section_security,
    SettingsSectionKind.support => settings_section_support,
    SettingsSectionKind.about => settings_section_about,
  };

  String settingsSectionHint(SettingsSectionKind kind) => switch (kind) {
    SettingsSectionKind.general => settings_sectionHint_general,
    SettingsSectionKind.theme => settings_sectionHint_theme,
    SettingsSectionKind.data => settings_sectionHint_data,
    SettingsSectionKind.security => settings_sectionHint_security,
    SettingsSectionKind.support => settings_sectionHint_support,
    SettingsSectionKind.about => settings_sectionHint_about,
  };

  String settingsNavItemTitle(String id) => switch (id) {
    'data_migration' => settings_dataMigration,
    'app_lock' => settings_appLock,
    'clear_data' => settings_clearData,
    'help_doc' => settings_helpDoc,
    'feedback' => settings_feedback,
    'user_agreement' => settings_userAgreement,
    'privacy_policy' => settings_privacyPolicy,
    'encryption_doc' => settings_encryptionDoc,
    'theme' => settings_themeDisplay,
    'language' => settings_language,
    'app_version' => settings_versionInfo,
    _ => id,
  };

  String? settingsNavItemSubtitle(
    String id, {
    AppLocalePreference? localePreference,
  }) => switch (id) {
    'language' when localePreference != null => settingsLanguageSummary(
      localePreference,
    ),
    'data_migration' => settings_dataMigrationSubtitle,
    'app_lock' => settings_appLockSubtitle,
    'clear_data' => settings_clearDataSubtitle,
    'theme' => settings_themeDisplaySubtitle,
    _ => null,
  };

  String settingsLanguageSummary(AppLocalePreference preference) =>
      switch (preference) {
        AppLocalePreference.system => settings_language_summary_system,
        AppLocalePreference.zhHans => settings_language_summary_zh_hans,
        AppLocalePreference.zhHant => settings_language_summary_zh_hant,
        AppLocalePreference.en => settings_language_summary_en,
        AppLocalePreference.ar => settings_language_summary_ar,
      };
}

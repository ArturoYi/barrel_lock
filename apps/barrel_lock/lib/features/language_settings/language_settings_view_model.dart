import 'package:core/core.dart';

import 'language_settings_coordinator.dart';

/// 语言设置页 ViewModel。
final class LanguageSettingsViewModel extends Notifier<AppLocalePreference> {
  @override
  AppLocalePreference build() {
    return ref.watch(localeSettingsProvider).preference;
  }

  Future<void> select(AppLocalePreference preference) async {
    await ref.read(localeSettingsProvider.notifier).setPreference(preference);
  }

  void onPop() => ref.read(languageSettingsCoordinatorProvider).pop();
}

final languageSettingsViewModelProvider =
    NotifierProvider<LanguageSettingsViewModel, AppLocalePreference>(
      LanguageSettingsViewModel.new,
    );

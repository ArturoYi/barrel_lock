import 'package:core/core.dart';

import 'settings_section.dart';
import 'settings_tab_coordinator.dart';
import 'settings_tab_model.dart';

/// 首页「设置」Tab 展示状态。
final class SettingsTabViewState {
  const SettingsTabViewState({
    required this.versionLabel,
    required this.sections,
    required this.selectedSection,
    required this.localePreference,
  });

  final String versionLabel;
  final List<SettingsSectionDescriptor> sections;

  /// 横屏 Master-Detail 当前选中分组。
  final SettingsSectionKind selectedSection;

  final AppLocalePreference localePreference;

  SettingsSectionDescriptor sectionOf(SettingsSectionKind kind) {
    return sections.firstWhere((section) => section.kind == kind);
  }
}

/// 首页「设置」Tab 状态与业务编排（MVVM-C 的 VM 层）。
final class SettingsTabViewModel extends Notifier<SettingsTabViewState> {
  /// 横屏选中分组；需在 [build] 重入（如语言切换）时保留。
  SettingsSectionKind _selectedSection = SettingsSectionKind.general;

  SettingsTabCoordinator get _coordinator =>
      ref.read(settingsTabCoordinatorProvider);

  @override
  SettingsTabViewState build() {
    final model = ref.read(settingsTabModelProvider);
    final localePreference = ref.watch(localeSettingsProvider).preference;
    return SettingsTabViewState(
      versionLabel: model.versionLabel,
      sections: model.sections,
      selectedSection: _selectedSection,
      localePreference: localePreference,
    );
  }

  void onSectionSelected(SettingsSectionKind kind) {
    _selectedSection = kind;
    state = SettingsTabViewState(
      versionLabel: state.versionLabel,
      sections: state.sections,
      selectedSection: kind,
      localePreference: state.localePreference,
    );
  }

  void onNavItemTap(String itemId) {
    switch (itemId) {
      case 'language':
        _coordinator.openLanguageSettings();
      case 'theme':
        onSectionSelected(SettingsSectionKind.theme);
      case 'data_migration':
        _coordinator.openDataMigration();
      case 'app_lock':
        _coordinator.openAppLock();
      case 'clear_data':
        _coordinator.openClearData();
      case 'help_doc':
      case 'feedback':
      case 'user_agreement':
      case 'privacy_policy':
      case 'encryption_doc':
        _coordinator.openSupportItem(itemId);
      case 'app_version':
        break;
    }
  }
}

final settingsTabViewModelProvider =
    NotifierProvider<SettingsTabViewModel, SettingsTabViewState>(
      SettingsTabViewModel.new,
    );

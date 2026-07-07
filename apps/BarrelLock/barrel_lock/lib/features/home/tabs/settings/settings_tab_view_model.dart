import 'package:core/core.dart';

import 'settings_section.dart';
import 'settings_tab_coordinator.dart';
import 'settings_tab_model.dart';

/// 首页「设置」Tab 展示状态。
final class SettingsTabViewState {
  const SettingsTabViewState({
    required this.title,
    required this.versionLabel,
    required this.sections,
    required this.selectedSection,
  });

  final String title;
  final String versionLabel;
  final List<SettingsSectionDescriptor> sections;

  /// 横屏 Master-Detail 当前选中分组。
  final SettingsSectionKind selectedSection;

  SettingsSectionDescriptor sectionOf(SettingsSectionKind kind) {
    return sections.firstWhere((section) => section.kind == kind);
  }
}

/// 首页「设置」Tab 状态与业务编排（MVVM-C 的 VM 层）。
final class SettingsTabViewModel extends Notifier<SettingsTabViewState> {
  late final SettingsTabModel _model;
  late final SettingsTabCoordinator _coordinator;

  @override
  SettingsTabViewState build() {
    _model = ref.read(settingsTabModelProvider);
    _coordinator = ref.read(settingsTabCoordinatorProvider);
    return SettingsTabViewState(
      title: _model.title,
      versionLabel: _model.versionLabel,
      sections: _model.sections,
      selectedSection: SettingsSectionKind.data,
    );
  }

  void onSectionSelected(SettingsSectionKind kind) {
    state = SettingsTabViewState(
      title: state.title,
      versionLabel: state.versionLabel,
      sections: state.sections,
      selectedSection: kind,
    );
  }

  void onNavItemTap(String itemId) {
    switch (itemId) {
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

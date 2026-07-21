import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../widgets/backup_restore_sheet.dart';
import '../widgets/bluetooth_backup_sheet.dart';
import '../widgets/settings_list_tile.dart';
import '../widgets/settings_section_card.dart';
import '../widgets/settings_subpage_scaffold.dart';

/// 数据迁移页（MVVM-C 的 V 层）：导出 / 导入等入口列表。
class DataMigrationPage extends ConsumerWidget {
  const DataMigrationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dataMigrationViewModelProvider);
    final viewModel = ref.read(dataMigrationViewModelProvider.notifier);

    ref.listen<DataMigrationViewState>(dataMigrationViewModelProvider, (
      _,
      next,
    ) {
      final request = next.uiRequest;
      if (request == null) {
        return;
      }

      viewModel.onUiRequestHandled();

      Future<void>(() async {
        if (!context.mounted) {
          return;
        }

        switch (request) {
          case RestoreBackupPickerRequest(:final backups):
            final selection = await showBackupRestoreSheet(context, backups);
            if (selection == null || !context.mounted) {
              return;
            }
            await viewModel.onRestoreConfirmed(selection.logId, selection.mode);
          case ImportModePickerRequest(:final bytes):
            final mode = await showBackupImportModeSheet(context);
            if (mode == null || !context.mounted) {
              return;
            }
            await viewModel.onImportModeConfirmed(bytes, mode);
          case BluetoothRolePickerRequest():
            final selection = await showBluetoothBackupSheet(context);
            if (selection == null || !context.mounted) {
              return;
            }
            viewModel.onBluetoothSessionSelected(selection);
        }
      });
    });

    return SettingsSubpageScaffold(
      title: '数据迁移',
      onBack: state.isBusy ? () {} : viewModel.onPop,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '在设备间安全迁移密码数据。导出文件均经加密处理。',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          SettingsSectionCard(
            children: [
              for (final action in state.actions)
                SettingsNavTile(
                  title: action.title,
                  subtitle: action.subtitle,
                  icon: action.icon,
                  onTap: state.isBusy
                      ? () {}
                      : () => viewModel.onActionTap(action.id),
                ),
            ],
          ),
          if (state.lastError != null) ...[
            const SizedBox(height: 16),
            Text(
              state.lastError!,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

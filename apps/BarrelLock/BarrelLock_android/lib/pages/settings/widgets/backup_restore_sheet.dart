import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 选择本地备份并确认恢复模式；取消返回 null。
Future<BackupRestoreSelection?> showBackupRestoreSheet(
  BuildContext context,
  List<BackupLogSummary> backups,
) {
  return showModalBottomSheet<BackupRestoreSelection>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _BackupRestoreSheet(backups: backups),
  );
}

/// 导入前选择合并或覆盖；取消返回 null。
Future<BackupImportMode?> showBackupImportModeSheet(BuildContext context) {
  return showModalBottomSheet<BackupImportMode>(
    context: context,
    builder: (context) => const _ImportModeSheet(),
  );
}

final class BackupRestoreSelection {
  const BackupRestoreSelection({required this.logId, required this.mode});

  final String logId;
  final BackupImportMode mode;
}

final class _BackupRestoreSheet extends StatefulWidget {
  const _BackupRestoreSheet({required this.backups});

  final List<BackupLogSummary> backups;

  @override
  State<_BackupRestoreSheet> createState() => _BackupRestoreSheetState();
}

final class _BackupRestoreSheetState extends State<_BackupRestoreSheet> {
  String? _selectedLogId;
  BackupImportMode _mode = BackupImportMode.merge;

  @override
  void initState() {
    super.initState();
    if (widget.backups.isNotEmpty) {
      _selectedLogId = widget.backups.first.logId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('恢复备份', style: context.textTheme.titleLarge),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.35,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.backups.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final backup = widget.backups[index];
                  final subtitle = _formatBackupTime(backup.backupTime);
                  return RadioListTile<String>(
                    value: backup.logId,
                    groupValue: _selectedLogId,
                    onChanged: (value) =>
                        setState(() => _selectedLogId = value),
                    title: Text(backup.note ?? '本地备份'),
                    subtitle: Text(subtitle),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<BackupImportMode>(
              segments: const [
                ButtonSegment(value: BackupImportMode.merge, label: Text('合并')),
                ButtonSegment(
                  value: BackupImportMode.replace,
                  label: Text('覆盖'),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (selection) {
                setState(() => _mode = selection.first);
              },
            ),
            if (_mode == BackupImportMode.replace) ...[
              const SizedBox(height: 8),
              Text(
                '覆盖将删除当前全部密码数据，且不可撤销。',
                style: context.textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _selectedLogId == null
                  ? null
                  : () {
                      Navigator.pop(
                        context,
                        BackupRestoreSelection(
                          logId: _selectedLogId!,
                          mode: _mode,
                        ),
                      );
                    },
              child: const Text('开始恢复'),
            ),
          ],
        ),
      ),
    );
  }
}

final class _ImportModeSheet extends StatelessWidget {
  const _ImportModeSheet();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('导入方式', style: context.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              '合并会保留本地独有条目；覆盖会用备份替换全部密码数据。',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(context, BackupImportMode.merge),
              child: const Text('合并导入'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
              onPressed: () => Navigator.pop(context, BackupImportMode.replace),
              child: const Text('覆盖导入'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatBackupTime(DateTime time) {
  final local = time.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.year}-$month-$day $hour:$minute';
}

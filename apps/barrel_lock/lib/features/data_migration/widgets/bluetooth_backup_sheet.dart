import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../backup_manage/backup_bluetooth_delegate.dart';
import '../../backup_manage/backup_bluetooth_transport_mode.dart';
import '../bluetooth_backup_session.dart';

/// 选择蓝牙迁移角色与传输模式；取消返回 null。
Future<BluetoothBackupSelection?> showBluetoothBackupSheet(
  BuildContext context,
) {
  return showModalBottomSheet<BluetoothBackupSelection>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _BluetoothBackupSheet(),
  );
}

final class _BluetoothBackupSheet extends StatelessWidget {
  const _BluetoothBackupSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('蓝牙共享', style: context.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              '传输完整加密备份。同系统使用附近连接；跨系统（iOS↔Android）使用 BLE，请保持两台设备在前台。',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Text('同系统附近连接', style: context.textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(
              'Android↔Android 或 iOS↔iOS',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.pop(
                context,
                const BluetoothBackupSelection(
                  role: BackupBluetoothRole.send,
                  transportMode: BackupBluetoothTransportMode.samePlatform,
                ),
              ),
              child: const Text('同系统 · 发送'),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: () => Navigator.pop(
                context,
                const BluetoothBackupSelection(
                  role: BackupBluetoothRole.receive,
                  transportMode: BackupBluetoothTransportMode.samePlatform,
                ),
              ),
              child: const Text('同系统 · 接收'),
            ),
            const SizedBox(height: 20),
            Text('跨平台 BLE', style: context.textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(
              'iOS 与 Android 互传；大备份可能需数分钟',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.pop(
                context,
                const BluetoothBackupSelection(
                  role: BackupBluetoothRole.send,
                  transportMode: BackupBluetoothTransportMode.crossPlatform,
                ),
              ),
              child: const Text('跨平台 · 发送'),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: () => Navigator.pop(
                context,
                const BluetoothBackupSelection(
                  role: BackupBluetoothRole.receive,
                  transportMode: BackupBluetoothTransportMode.crossPlatform,
                ),
              ),
              child: const Text('跨平台 · 接收'),
            ),
          ],
        ),
      ),
    );
  }
}

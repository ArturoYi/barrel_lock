import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 蓝牙 P2P 共享页（发送 / 接收）。
class BluetoothBackupPage extends ConsumerWidget {
  const BluetoothBackupPage({
    super.key,
    required this.role,
    this.transportMode = BackupBluetoothTransportMode.samePlatform,
  });

  final BackupBluetoothRole role;
  final BackupBluetoothTransportMode transportMode;

  BluetoothBackupSessionKey get _session =>
      BluetoothBackupSessionKey(role: role, transportMode: transportMode);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = bluetoothBackupViewModelProvider(_session);
    final state = ref.watch(provider);
    final viewModel = ref.read(provider.notifier);

    ref.listen(provider, (_, next) {
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
          case BluetoothImportModePickerRequest(:final bytes):
            final mode = await _showImportModeSheet(context);
            if (mode == null || !context.mounted) {
              return;
            }
            await viewModel.onImportModeConfirmed(bytes, mode);
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: viewModel.onCancel),
        title: Text(_roleTitle(state)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CountdownBanner(secondsRemaining: state.secondsRemaining),
              const SizedBox(height: 16),
              _StatusCard(state: state),
              const SizedBox(height: 16),
              Expanded(
                child: _PeerSection(
                  state: state,
                  onPeerSelected: viewModel.onPeerSelected,
                ),
              ),
              if (state.progress case final progress?) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 4),
                Text(
                  '${(progress.clamp(0.0, 1.0) * 100).round()}%',
                  textAlign: TextAlign.center,
                  style: context.textTheme.labelLarge,
                ),
              ],
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: viewModel.onCancel,
                child: const Text('取消'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _roleTitle(BluetoothBackupViewState state) {
    if (state.isCrossPlatform) {
      return switch (state.role) {
        BackupBluetoothRole.send => '跨平台发送',
        BackupBluetoothRole.receive => '跨平台接收',
      };
    }
    return switch (state.role) {
      BackupBluetoothRole.send => '发送到附近设备',
      BackupBluetoothRole.receive => '从附近设备接收',
    };
  }

  Future<BackupImportMode?> _showImportModeSheet(BuildContext context) {
    return showModalBottomSheet<BackupImportMode>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('选择导入方式', style: context.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  '合并会保留本机已有数据；覆盖会先清空再导入，请谨慎选择。',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      Navigator.pop(context, BackupImportMode.merge),
                  child: const Text('合并导入'),
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    foregroundColor: context.colors.error,
                  ),
                  onPressed: () =>
                      Navigator.pop(context, BackupImportMode.replace),
                  child: const Text('覆盖导入（危险）'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

final class _CountdownBanner extends StatelessWidget {
  const _CountdownBanner({required this.secondsRemaining});

  final int secondsRemaining;

  @override
  Widget build(BuildContext context) {
    final minutes = secondsRemaining ~/ 60;
    final seconds = secondsRemaining % 60;
    final label =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_outlined, color: context.colors.onPrimaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '剩余连接时间 $label',
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.state});

  final BluetoothBackupViewState state;

  @override
  Widget build(BuildContext context) {
    final isError = state.phase == BackupBluetoothPhase.failed;
    final icon = switch (state.phase) {
      BackupBluetoothPhase.completed => Icons.check_circle_outline,
      BackupBluetoothPhase.failed => Icons.error_outline,
      BackupBluetoothPhase.transferring => Icons.sync,
      _ => Icons.bluetooth_searching,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (state.isActive)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                icon,
                color: isError ? context.colors.error : context.colors.primary,
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.statusMessage ?? '',
                    style: context.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _phaseHint(state),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _phaseHint(BluetoothBackupViewState state) {
    if (state.phase == BackupBluetoothPhase.transferring &&
        state.progress != null) {
      final percent = (state.progress!.clamp(0.0, 1.0) * 100).round();
      return '传输进度 $percent%';
    }
    if (state.isCrossPlatform) {
      return switch (state.role) {
        BackupBluetoothRole.send => '请在对端选择「跨平台 · 接收」并保持前台',
        BackupBluetoothRole.receive => '请在对端选择「跨平台 · 发送」并保持前台',
      };
    }
    return switch (state.role) {
      BackupBluetoothRole.send => '请在对端选择「同系统 · 接收」',
      BackupBluetoothRole.receive => '请在对端选择「同系统 · 发送」',
    };
  }
}

final class _PeerSection extends StatelessWidget {
  const _PeerSection({required this.state, required this.onPeerSelected});

  final BluetoothBackupViewState state;
  final Future<void> Function(BackupBluetoothPeer peer) onPeerSelected;

  @override
  Widget build(BuildContext context) {
    if (state.role == BackupBluetoothRole.receive) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.devices_other_outlined,
              size: 64,
              color: context.colors.outline,
            ),
            const SizedBox(height: 16),
            Text(
              state.isCrossPlatform ? '本机已就绪，等待跨平台发送端连接' : '本机已就绪，等待发送端连接',
              style: context.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              state.isCrossPlatform
                  ? '保持本页在前台；跨平台 BLE 传输可能需数分钟'
                  : '保持本页在前台，并确保两台设备为同一系统',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (state.peers.isEmpty) {
      return Center(
        child: Text(
          state.isCrossPlatform ? '暂未发现跨平台接收端' : '暂未发现可接收的设备',
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          state.isCrossPlatform ? '可连接的跨平台设备' : '附近可接收设备',
          style: context.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            itemCount: state.peers.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final peer = state.peers[index];
              final isSelected = state.selectedPeerId == peer.id;
              final isConnecting =
                  isSelected &&
                  (state.phase == BackupBluetoothPhase.connecting ||
                      state.phase == BackupBluetoothPhase.transferring);
              return ListTile(
                enabled: state.canSelectPeer || isSelected,
                onTap: state.canSelectPeer ? () => onPeerSelected(peer) : null,
                leading: const Icon(Icons.smartphone_outlined),
                title: Text(peer.displayName),
                subtitle: Text(
                  isConnecting
                      ? '正在连接并传输…'
                      : state.canSelectPeer
                      ? '点击开始传输'
                      : '等待选择设备',
                ),
                trailing: isConnecting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : state.canSelectPeer
                    ? const Icon(Icons.chevron_right)
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }
}

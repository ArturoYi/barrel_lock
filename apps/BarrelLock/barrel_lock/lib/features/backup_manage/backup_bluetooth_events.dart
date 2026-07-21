/// 蓝牙 P2P 会话阶段。
enum BackupBluetoothPhase {
  idle,
  discovering,
  connecting,
  transferring,
  completed,
  failed,
  cancelled,
}

/// 发现的附近设备。
final class BackupBluetoothPeer {
  const BackupBluetoothPeer({required this.id, required this.displayName});

  final String id;
  final String displayName;
}

/// 蓝牙 P2P 会话事件（由平台 EventChannel 推送）。
sealed class BackupBluetoothEvent {
  const BackupBluetoothEvent();

  factory BackupBluetoothEvent.fromMap(Map<Object?, Object?> map) {
    final type = map['type'] as String? ?? '';
    return switch (type) {
      'phase' => BackupBluetoothPhaseChanged(
        _parsePhase(map['phase'] as String?),
        message: map['message'] as String?,
      ),
      'peerFound' => BackupBluetoothPeerFound(
        BackupBluetoothPeer(
          id: map['peerId'] as String? ?? '',
          displayName: map['displayName'] as String? ?? '未知设备',
        ),
      ),
      'peerLost' => BackupBluetoothPeerLost(map['peerId'] as String? ?? ''),
      'progress' => BackupBluetoothProgressChanged(
        (map['value'] as num? ?? 0).toDouble().clamp(0, 1),
      ),
      'error' => BackupBluetoothSessionError(
        map['message'] as String? ?? '传输失败',
      ),
      _ => const BackupBluetoothUnknownEvent(),
    };
  }
}

final class BackupBluetoothPhaseChanged extends BackupBluetoothEvent {
  const BackupBluetoothPhaseChanged(this.phase, {this.message});

  final BackupBluetoothPhase phase;
  final String? message;
}

final class BackupBluetoothPeerFound extends BackupBluetoothEvent {
  const BackupBluetoothPeerFound(this.peer);

  final BackupBluetoothPeer peer;
}

final class BackupBluetoothPeerLost extends BackupBluetoothEvent {
  const BackupBluetoothPeerLost(this.peerId);

  final String peerId;
}

final class BackupBluetoothProgressChanged extends BackupBluetoothEvent {
  const BackupBluetoothProgressChanged(this.progress);

  final double progress;
}

final class BackupBluetoothSessionError extends BackupBluetoothEvent {
  const BackupBluetoothSessionError(this.message);

  final String message;
}

final class BackupBluetoothUnknownEvent extends BackupBluetoothEvent {
  const BackupBluetoothUnknownEvent();
}

BackupBluetoothPhase _parsePhase(String? raw) {
  for (final phase in BackupBluetoothPhase.values) {
    if (phase.name == raw) {
      return phase;
    }
  }
  return BackupBluetoothPhase.idle;
}

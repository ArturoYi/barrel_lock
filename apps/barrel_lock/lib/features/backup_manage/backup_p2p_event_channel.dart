import 'package:flutter/services.dart';

import 'backup_bluetooth_events.dart';

/// 蓝牙 P2P 会话 EventChannel（iOS / Android 原生层统一事件名）。
abstract final class BackupP2pEventChannel {
  static const _channel = EventChannel('com.barrellock/backup_p2p_events');

  static Stream<BackupBluetoothEvent> watch() {
    return _channel.receiveBroadcastStream().map((event) {
      if (event is Map) {
        return BackupBluetoothEvent.fromMap(event.cast<Object?, Object?>());
      }
      return const BackupBluetoothUnknownEvent();
    });
  }
}

import 'dart:async';
import 'dart:typed_data';

import 'package:core/core.dart';

import '../backup_manage/backup_manage.dart';
import 'bluetooth_backup_coordinator.dart';
import 'bluetooth_backup_session.dart';

/// 蓝牙共享页 UI 请求。
sealed class BluetoothBackupUiRequest {
  const BluetoothBackupUiRequest();
}

final class BluetoothImportModePickerRequest extends BluetoothBackupUiRequest {
  const BluetoothImportModePickerRequest(this.bytes);

  final Uint8List bytes;
}

/// 蓝牙共享页状态。
final class BluetoothBackupViewState {
  const BluetoothBackupViewState({
    required this.role,
    required this.transportMode,
    this.phase = BackupBluetoothPhase.idle,
    this.peers = const [],
    this.selectedPeerId,
    required this.secondsRemaining,
    this.progress,
    this.statusMessage,
    this.errorMessage,
    this.uiRequest,
  });

  static const samePlatformTimeoutSeconds = 120;
  static const crossPlatformTimeoutSeconds = 180;

  static int timeoutSecondsFor(BackupBluetoothTransportMode mode) {
    return switch (mode) {
      BackupBluetoothTransportMode.samePlatform => samePlatformTimeoutSeconds,
      BackupBluetoothTransportMode.crossPlatform => crossPlatformTimeoutSeconds,
    };
  }

  final BackupBluetoothRole role;
  final BackupBluetoothTransportMode transportMode;
  final BackupBluetoothPhase phase;
  final List<BackupBluetoothPeer> peers;
  final String? selectedPeerId;
  final int secondsRemaining;
  final double? progress;
  final String? statusMessage;
  final String? errorMessage;
  final BluetoothBackupUiRequest? uiRequest;

  bool get isCrossPlatform =>
      transportMode == BackupBluetoothTransportMode.crossPlatform;

  bool get isActive =>
      phase == BackupBluetoothPhase.discovering ||
      phase == BackupBluetoothPhase.connecting ||
      phase == BackupBluetoothPhase.transferring;

  bool get canSelectPeer =>
      role == BackupBluetoothRole.send &&
      phase == BackupBluetoothPhase.discovering &&
      selectedPeerId == null;

  BluetoothBackupViewState copyWith({
    BackupBluetoothPhase? phase,
    List<BackupBluetoothPeer>? peers,
    String? selectedPeerId,
    int? secondsRemaining,
    double? progress,
    String? statusMessage,
    String? errorMessage,
    BluetoothBackupUiRequest? uiRequest,
    bool clearUiRequest = false,
    bool clearError = false,
    bool clearProgress = false,
    bool clearSelectedPeer = false,
  }) {
    return BluetoothBackupViewState(
      role: role,
      transportMode: transportMode,
      phase: phase ?? this.phase,
      peers: peers ?? this.peers,
      selectedPeerId: clearSelectedPeer
          ? null
          : (selectedPeerId ?? this.selectedPeerId),
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      progress: clearProgress ? null : (progress ?? this.progress),
      statusMessage: statusMessage ?? this.statusMessage,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      uiRequest: clearUiRequest ? null : (uiRequest ?? this.uiRequest),
    );
  }
}

/// 蓝牙共享页 ViewModel（family：角色 + 传输模式）。
final class BluetoothBackupViewModel
    extends Notifier<BluetoothBackupViewState> {
  BluetoothBackupViewModel(this._session);

  final BluetoothBackupSessionKey _session;

  late final BackupManageModel _backupManage;
  late final BackupBluetoothDelegate _bluetoothDelegate;
  late final BluetoothBackupCoordinator _coordinator;

  StreamSubscription<BackupBluetoothEvent>? _eventSubscription;
  Timer? _countdownTimer;
  var _failureHandled = false;

  @override
  BluetoothBackupViewState build() {
    _backupManage = ref.read(backupManageModelProvider);
    _bluetoothDelegate = ref.read(
      backupBluetoothDelegateForModeProvider(_session.transportMode),
    );
    _coordinator = ref.read(bluetoothBackupCoordinatorProvider);

    ref.onDispose(_disposeSession);

    final initial = BluetoothBackupViewState(
      role: _session.role,
      transportMode: _session.transportMode,
      secondsRemaining: BluetoothBackupViewState.timeoutSecondsFor(
        _session.transportMode,
      ),
      statusMessage: _initialStatusMessage(),
    );

    Future.microtask(_startSession);
    return initial;
  }

  void onUiRequestHandled() {
    state = state.copyWith(clearUiRequest: true);
  }

  Future<void> onPeerSelected(BackupBluetoothPeer peer) async {
    if (!state.canSelectPeer) {
      return;
    }
    state = state.copyWith(
      selectedPeerId: peer.id,
      phase: BackupBluetoothPhase.connecting,
      statusMessage: '正在连接 ${peer.displayName}…',
    );
    try {
      await _bluetoothDelegate.connectToPeer(peer.id);
    } on BackupBluetoothException catch (error) {
      _handleFailure(error.message);
    } catch (error) {
      _handleFailure('连接失败：$error');
    }
  }

  Future<void> onCancel() async {
    await _bluetoothDelegate.cancel();
    _stopCountdown();
    state = state.copyWith(
      phase: BackupBluetoothPhase.cancelled,
      statusMessage: '已取消',
    );
    _coordinator.pop();
  }

  Future<void> onImportModeConfirmed(
    Uint8List bytes,
    BackupImportMode mode,
  ) async {
    try {
      if (mode == BackupImportMode.replace) {
        await _backupManage.createLocalBackup(note: '蓝牙导入前自动快照');
      }
      await _backupManage.restoreFromBytes(bytes, mode: mode);
      FastToast.show('导入完成');
      _coordinator.pop();
    } on BackupManageException catch (error) {
      state = state.copyWith(errorMessage: error.message);
      FastToast.show(error.message);
    } on BackupArchiveException catch (error) {
      state = state.copyWith(errorMessage: error.message);
      FastToast.show(error.message);
    } catch (error) {
      state = state.copyWith(errorMessage: '$error');
      FastToast.show('导入失败');
    }
  }

  Future<void> _startSession() async {
    _listenEvents();
    _startCountdown();

    state = state.copyWith(
      phase: BackupBluetoothPhase.discovering,
      clearError: true,
    );

    try {
      if (_session.role == BackupBluetoothRole.send) {
        final bytes = await _backupManage.createSnapshotBytes();
        await _bluetoothDelegate.sendBackup(
          bytes: bytes,
          onProgress: _onProgress,
        );
        state = state.copyWith(
          phase: BackupBluetoothPhase.completed,
          progress: 1,
          statusMessage: state.isCrossPlatform ? '备份已发送到跨平台设备' : '备份已发送到附近设备',
        );
        FastToast.show('发送完成');
        await Future<void>.delayed(const Duration(seconds: 1));
        if (ref.mounted) {
          _coordinator.pop();
        }
      } else {
        final bytes = await _bluetoothDelegate.receiveBackup(
          onProgress: _onProgress,
        );
        if (!ref.mounted) {
          return;
        }
        if (bytes == null) {
          return;
        }
        await BackupArchiveCodec.decode(bytes);
        state = state.copyWith(
          phase: BackupBluetoothPhase.completed,
          progress: 1,
          statusMessage: '已收到备份，请选择导入方式',
        );
        state = state.copyWith(
          uiRequest: BluetoothImportModePickerRequest(bytes),
        );
      }
    } on BackupBluetoothException catch (error) {
      _handleFailure(error.message);
    } catch (error) {
      _handleFailure('传输失败：$error');
    }
  }

  void _listenEvents() {
    _eventSubscription?.cancel();
    _eventSubscription = _bluetoothDelegate.events.listen((event) {
      if (!ref.mounted) {
        return;
      }
      switch (event) {
        case BackupBluetoothPhaseChanged(:final phase, :final message):
          state = state.copyWith(
            phase: phase,
            statusMessage: message ?? _defaultMessageForPhase(phase),
            clearSelectedPeer: phase == BackupBluetoothPhase.discovering,
          );
        case BackupBluetoothPeerFound(:final peer):
          if (_session.role != BackupBluetoothRole.send) {
            return;
          }
          final peers = [...state.peers];
          final index = peers.indexWhere((item) => item.id == peer.id);
          if (index >= 0) {
            peers[index] = peer;
          } else {
            peers.add(peer);
          }
          state = state.copyWith(peers: peers);
        case BackupBluetoothPeerLost(:final peerId):
          state = state.copyWith(
            peers: state.peers.where((peer) => peer.id != peerId).toList(),
          );
        case BackupBluetoothProgressChanged(:final progress):
          _onProgress(progress);
        case BackupBluetoothSessionError(:final message):
          _handleFailure(message);
        case BackupBluetoothUnknownEvent():
          break;
      }
    });
  }

  void _onProgress(double progress) {
    final percent = (progress.clamp(0.0, 1.0) * 100).round();
    state = state.copyWith(
      phase: BackupBluetoothPhase.transferring,
      progress: progress,
      statusMessage: state.isCrossPlatform
          ? '正在通过 BLE 传输加密备份… $percent%'
          : '正在传输加密备份… $percent%',
    );
  }

  void _handleFailure(String message) {
    if (_failureHandled) {
      return;
    }
    _failureHandled = true;
    _stopCountdown();
    state = state.copyWith(
      phase: BackupBluetoothPhase.failed,
      errorMessage: message,
      statusMessage: message,
    );
    FastToast.show(message);
  }

  String _initialStatusMessage() {
    if (_session.transportMode == BackupBluetoothTransportMode.crossPlatform) {
      return _session.role == BackupBluetoothRole.send
          ? '正在扫描跨平台接收端…'
          : '等待跨平台发送端连接…';
    }
    return _session.role == BackupBluetoothRole.send ? '正在搜索附近设备…' : '等待发送端连接…';
  }

  String _defaultMessageForPhase(BackupBluetoothPhase phase) {
    return switch (phase) {
      BackupBluetoothPhase.discovering => _initialStatusMessage(),
      BackupBluetoothPhase.connecting => '正在连接…',
      BackupBluetoothPhase.transferring =>
        state.isCrossPlatform ? '正在通过 BLE 传输加密备份…' : '正在传输加密备份…',
      BackupBluetoothPhase.completed => '传输完成',
      BackupBluetoothPhase.failed => state.errorMessage ?? '传输失败',
      BackupBluetoothPhase.cancelled => '已取消',
      BackupBluetoothPhase.idle => '',
    };
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!ref.mounted) {
        return;
      }
      final next = state.secondsRemaining - 1;
      if (next <= 0) {
        _stopCountdown();
        return;
      }
      state = state.copyWith(secondsRemaining: next);
    });
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  void _disposeSession() {
    _eventSubscription?.cancel();
    _stopCountdown();
    unawaited(_bluetoothDelegate.cancel());
  }
}

final bluetoothBackupViewModelProvider = NotifierProvider.autoDispose
    .family<
      BluetoothBackupViewModel,
      BluetoothBackupViewState,
      BluetoothBackupSessionKey
    >(BluetoothBackupViewModel.new);

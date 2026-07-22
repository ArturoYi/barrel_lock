import 'dart:typed_data';

import 'package:core/core.dart';

import '../backup_manage/backup_manage.dart';
import 'bluetooth_backup_coordinator.dart';
import 'bluetooth_backup_session.dart';
import 'data_migration_coordinator.dart';
import 'data_migration_model.dart';

/// 数据迁移页待展示的 UI 请求（由 View 消费后调用 [DataMigrationViewModel.onUiRequestHandled]）。
sealed class DataMigrationUiRequest {
  const DataMigrationUiRequest();
}

/// 展示本地备份列表并选择恢复项。
final class RestoreBackupPickerRequest extends DataMigrationUiRequest {
  const RestoreBackupPickerRequest(this.backups);

  final List<BackupLogSummary> backups;
}

/// 导入前选择 merge / replace。
final class ImportModePickerRequest extends DataMigrationUiRequest {
  const ImportModePickerRequest(this.bytes);

  final Uint8List bytes;
}

/// 蓝牙迁移：选择发送或接收。
final class BluetoothRolePickerRequest extends DataMigrationUiRequest {
  const BluetoothRolePickerRequest();
}

/// 数据迁移页展示状态。
final class DataMigrationViewState {
  const DataMigrationViewState({
    required this.actions,
    this.isBusy = false,
    this.lastError,
    this.uiRequest,
  });

  final List<DataMigrationAction> actions;
  final bool isBusy;
  final String? lastError;
  final DataMigrationUiRequest? uiRequest;

  DataMigrationViewState copyWith({
    List<DataMigrationAction>? actions,
    bool? isBusy,
    String? lastError,
    DataMigrationUiRequest? uiRequest,
    bool clearUiRequest = false,
    bool clearError = false,
  }) {
    return DataMigrationViewState(
      actions: actions ?? this.actions,
      isBusy: isBusy ?? this.isBusy,
      lastError: clearError ? null : (lastError ?? this.lastError),
      uiRequest: clearUiRequest ? null : (uiRequest ?? this.uiRequest),
    );
  }
}

/// 数据迁移页状态与业务编排（MVVM-C 的 VM 层）。
final class DataMigrationViewModel extends Notifier<DataMigrationViewState> {
  late final DataMigrationModel _model;
  late final DataMigrationCoordinator _coordinator;
  late final BluetoothBackupCoordinator _bluetoothCoordinator;
  late final BackupManageModel _backupManage;
  late final BackupFileDelegate _fileDelegate;

  @override
  DataMigrationViewState build() {
    _model = ref.read(dataMigrationModelProvider);
    _coordinator = ref.read(dataMigrationCoordinatorProvider);
    _bluetoothCoordinator = ref.read(bluetoothBackupCoordinatorProvider);
    _backupManage = ref.read(backupManageModelProvider);
    _fileDelegate = ref.read(backupFileDelegateProvider);
    return DataMigrationViewState(actions: _model.actions);
  }

  void onPop() => _coordinator.pop();

  void onUiRequestHandled() {
    state = state.copyWith(clearUiRequest: true);
  }

  Future<void> onActionTap(String actionId) async {
    if (state.isBusy) {
      return;
    }

    switch (actionId) {
      case 'backup':
        await _createLocalBackup();
      case 'restore':
        await _requestRestorePicker();
      case 'export_file':
        await _exportToFile();
      case 'import_file':
        await _importFromFile();
      case 'bluetooth_share':
        state = state.copyWith(uiRequest: const BluetoothRolePickerRequest());
      default:
        FastToast.show('「$actionId」功能开发中');
    }
  }

  Future<void> onRestoreConfirmed(String logId, BackupImportMode mode) async {
    if (state.isBusy) {
      return;
    }

    state = state.copyWith(isBusy: true, clearError: true);
    try {
      await _backupManage.restoreFromLocalBackup(logId, mode: mode);
      FastToast.show('恢复完成');
    } on BackupManageException catch (error) {
      state = state.copyWith(isBusy: false, lastError: error.message);
      FastToast.show(error.message);
      return;
    } on BackupArchiveException catch (error) {
      state = state.copyWith(isBusy: false, lastError: error.message);
      FastToast.show(error.message);
      return;
    } catch (error) {
      state = state.copyWith(isBusy: false, lastError: '$error');
      FastToast.show('恢复失败');
      return;
    }

    state = state.copyWith(isBusy: false, clearError: true);
  }

  Future<void> onImportModeConfirmed(
    Uint8List bytes,
    BackupImportMode mode,
  ) async {
    if (state.isBusy) {
      return;
    }

    state = state.copyWith(isBusy: true, clearError: true);
    try {
      if (mode == BackupImportMode.replace) {
        await _backupManage.createLocalBackup(note: '导入前自动快照');
      }
      await _backupManage.restoreFromBytes(bytes, mode: mode);
      FastToast.show('导入完成');
    } on BackupManageException catch (error) {
      state = state.copyWith(isBusy: false, lastError: error.message);
      FastToast.show(error.message);
      return;
    } on BackupArchiveException catch (error) {
      state = state.copyWith(isBusy: false, lastError: error.message);
      FastToast.show(error.message);
      return;
    } catch (error) {
      state = state.copyWith(isBusy: false, lastError: '$error');
      FastToast.show('导入失败');
      return;
    }

    state = state.copyWith(isBusy: false, clearError: true);
  }

  Future<void> _createLocalBackup() async {
    state = state.copyWith(isBusy: true, clearError: true);
    try {
      await _backupManage.createLocalBackup();
      FastToast.show('本地备份已创建');
    } on BackupManageException catch (error) {
      state = state.copyWith(isBusy: false, lastError: error.message);
      FastToast.show(error.message);
      return;
    } catch (error) {
      state = state.copyWith(isBusy: false, lastError: '$error');
      FastToast.show('备份失败');
      return;
    }
    state = state.copyWith(isBusy: false, clearError: true);
  }

  Future<void> _requestRestorePicker() async {
    final backups = await _backupManage.watchRecentBackups().first;
    if (backups.isEmpty) {
      FastToast.show('暂无本地备份');
      return;
    }
    state = state.copyWith(uiRequest: RestoreBackupPickerRequest(backups));
  }

  Future<void> _exportToFile() async {
    state = state.copyWith(isBusy: true, clearError: true);
    try {
      final bytes = await _backupManage.createSnapshotBytes();
      final suggestedName =
          'barrel-lock-${DateTime.now().toUtc().millisecondsSinceEpoch}.${BackupArchiveCodec.fileExtension}';
      final savedPath = await _fileDelegate.saveBackupFile(
        suggestedName: suggestedName,
        bytes: bytes,
      );
      if (savedPath == null) {
        await _fileDelegate.shareBackupFile(
          suggestedName: suggestedName,
          bytes: bytes,
        );
      } else {
        FastToast.show('已导出备份');
      }
    } on BackupManageException catch (error) {
      state = state.copyWith(isBusy: false, lastError: error.message);
      FastToast.show(error.message);
      return;
    } catch (error) {
      state = state.copyWith(isBusy: false, lastError: '$error');
      FastToast.show('导出失败');
      return;
    }
    state = state.copyWith(isBusy: false, clearError: true);
  }

  Future<void> _importFromFile() async {
    final bytes = await _fileDelegate.pickBackupFile();
    if (bytes == null) {
      return;
    }

    try {
      await BackupArchiveCodec.decode(bytes);
    } on BackupArchiveException catch (error) {
      FastToast.show(error.message);
      return;
    }

    state = state.copyWith(uiRequest: ImportModePickerRequest(bytes));
  }

  Future<void> onBluetoothSessionSelected(
    BluetoothBackupSelection selection,
  ) async {
    _bluetoothCoordinator.openSession(selection.sessionKey);
  }
}

final dataMigrationViewModelProvider =
    NotifierProvider<DataMigrationViewModel, DataMigrationViewState>(
      DataMigrationViewModel.new,
    );

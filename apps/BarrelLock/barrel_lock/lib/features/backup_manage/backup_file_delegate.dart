import 'dart:typed_data';

/// 平台文件导出/导入委托；由各 app 通过 Riverpod override 注入。
abstract class BackupFileDelegate {
  const BackupFileDelegate();

  /// 保存备份文件；用户取消时返回 null。
  Future<String?> saveBackupFile({
    required String suggestedName,
    required Uint8List bytes,
  });

  /// 选择 `.blbak` 文件；用户取消时返回 null。
  Future<Uint8List?> pickBackupFile();

  /// 通过系统分享面板导出备份。
  Future<void> shareBackupFile({
    required String suggestedName,
    required Uint8List bytes,
  });
}

/// 未注入平台实现时的占位委托。
final class UnavailableBackupFileDelegate extends BackupFileDelegate {
  const UnavailableBackupFileDelegate();

  @override
  Future<String?> saveBackupFile({
    required String suggestedName,
    required Uint8List bytes,
  }) async {
    return null;
  }

  @override
  Future<Uint8List?> pickBackupFile() async => null;

  @override
  Future<void> shareBackupFile({
    required String suggestedName,
    required Uint8List bytes,
  }) async {}
}

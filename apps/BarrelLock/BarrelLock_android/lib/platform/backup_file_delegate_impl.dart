import 'dart:io';
import 'dart:typed_data';

import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';

/// Android 备份文件导出/导入实现。
final class AndroidBackupFileDelegate extends BackupFileDelegate {
  const AndroidBackupFileDelegate();

  @override
  Future<String?> saveBackupFile({
    required String suggestedName,
    required Uint8List bytes,
  }) async {
    return FilePicker.saveFile(
      dialogTitle: '导出备份',
      fileName: suggestedName,
      bytes: bytes,
    );
  }

  @override
  Future<Uint8List?> pickBackupFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: [BackupArchiveCodec.fileExtension],
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      return null;
    }
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes != null) {
      return bytes;
    }
    final path = file.path;
    if (path == null) {
      return null;
    }
    return File(path).readAsBytes();
  }

  @override
  Future<void> shareBackupFile({
    required String suggestedName,
    required Uint8List bytes,
  }) async {
    final directory = await Directory.systemTemp.createTemp(
      'barrel_lock_export',
    );
    final file = File('${directory.path}/$suggestedName');
    await file.writeAsBytes(bytes, flush: true);
    await Share.shareXFiles([XFile(file.path)], text: 'BarrelLock 备份');
  }
}

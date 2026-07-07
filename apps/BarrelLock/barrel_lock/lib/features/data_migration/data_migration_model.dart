import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 数据迁移操作项。
final class DataMigrationAction {
  const DataMigrationAction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
}

/// 数据迁移页业务数据（MVVM-C 的 M 层）。
final class DataMigrationModel {
  const DataMigrationModel();

  List<DataMigrationAction> get actions => const [
    DataMigrationAction(
      id: 'export_file',
      title: '导出到文件',
      subtitle: '加密打包后保存到本地',
      icon: Icons.upload_file_outlined,
    ),
    DataMigrationAction(
      id: 'import_file',
      title: '从文件导入',
      subtitle: '合并或覆盖现有数据',
      icon: Icons.download_outlined,
    ),
    DataMigrationAction(
      id: 'bluetooth_share',
      title: '蓝牙共享',
      subtitle: '与附近设备传输备份',
      icon: Icons.bluetooth_outlined,
    ),
    DataMigrationAction(
      id: 'backup',
      title: '本地备份',
      subtitle: '在应用内保留一份快照',
      icon: Icons.backup_outlined,
    ),
    DataMigrationAction(
      id: 'restore',
      title: '恢复备份',
      subtitle: '从最近备份还原',
      icon: Icons.restore_outlined,
    ),
  ];
}

final dataMigrationModelProvider = Provider<DataMigrationModel>(
  (_) => const DataMigrationModel(),
);

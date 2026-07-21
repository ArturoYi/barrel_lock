import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 选择文件夹 BottomSheet（未分组 + 已有 + 新建）。
Future<String?> showCipherDetailFolderSheet({
  required BuildContext context,
  required DetailFolderState folderState,
  required Future<String?> Function() onCreateFolder,
}) {
  return showModalBottomSheet<String?>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '选择文件夹',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ListTile(
              title: const Text('未分组'),
              onTap: () => Navigator.of(context).pop(null),
            ),
            for (final folder in folderState.folders)
              ListTile(
                title: Text(folder.name),
                onTap: () => Navigator.of(context).pop(folder.id),
              ),
            ListTile(
              leading: const Icon(Icons.create_new_folder_outlined),
              title: const Text('新建文件夹…'),
              onTap: () async {
                Navigator.of(context).pop(DetailFolderState.createNewSentinel);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  ).then((value) async {
    if (value == DetailFolderState.createNewSentinel) {
      return onCreateFolder();
    }
    return value;
  });
}

Future<bool> showCipherDetailDeleteDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('删除密码'),
      content: const Text('删除后将移出密码列表，此操作不可撤销。'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('删除'),
        ),
      ],
    ),
  );
  return result ?? false;
}
